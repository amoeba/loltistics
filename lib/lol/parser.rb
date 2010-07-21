module LOL
   def self.parse(message)
    message = message.split $/ # Split into lines so we can...
    message.shift # Remove the first line of the log

    stack = [{}]
    context, new_parent = nil, nil
    key, val = '', ''

    message.each_with_index do |line, i|
      context = stack.last
      next_line = message[i+1]

      level = line.scan('  ').length
      next_level = next_line ? next_line.scan('  ').length : nil

      # Parent Object
      if next_line and next_level > level
        if line.match '^ *\['
          new_parent = {}
          context.push new_parent
          stack.push new_parent
        else
          tokens = line.match '([_\w]+) ='
    
          if next_line.match '^ *\['
            if tokens && tokens.length == 2
              key = tokens[1]
        
              context[key] = []
              stack.push context[key]
            end
          else
            if tokens && tokens.length == 2
              key = tokens[1]
        
              context[key] = {}
              stack.push context[key]
            end
          end
        end 
      # Not a parent object
      else
        if line.match '='
          tokens = line.match '([_\w]+) = (.+)'
          key, val = tokens[1], tokens[2] if tokens and tokens.length == 3

          # Remove extra double-quotes
          val.delete! '\"'
          
          # Ignore useless properties, where:
          #   - Value is an empty string
          #   - Value is (null)
          #   - Value is a reference to an Array that doesn't exist
          #   
          unless val.empty? or val == "(null)" or val.match('\(Array\)#.*')
            context[key] = val 
          end
        else
          val = line.match '\[\d+\] (.+)'
          context.push val[1]
        end

      end

      if next_line and next_level < level
        (level - next_level).times do
          stack.pop
        end
      end
    end

    stack.first
  end

  def self.parse_file(content)
    @messages = content.split /^\d+\/\d+\/\d+ \d+:\d+:\d+\.\d+ /
    @locale, @matches, @players = nil, {}, {}

    match, match_key = nil, ''
    items, finding_items = [], false

    @messages.each do |message|
      # Locale
      @locale = (message.scan 'locale = en_US') ? 'US' : 'EU'

      # GameDTO
      if message.match 'gameState = "TERMINATED"'
        dto = parse(message)
        match_key = @locale + dto['body']['id']
  
        @matches[match_key] ||= {}
        @matches[match_key].merge!({
          :id => match_key,
          :map_id => dto['body']['mapId'],
          :created => dto['body']['creationTime']
        })
      end

      # EndOfGameStats
      if message.match 'EndOfGameStats\)#1'
        eog = parse(message)
        match_key = @locale + eog['body']['gameId']
  
        @matches[match_key] ||= {}
        @matches[match_key].merge!({
          :queue_type => eog['body']['queueType'],
          :game_length => eog['body']['gameLength'],
          :game_type => eog['body']['gameType'],
          :ranked => eog['body']['ranked'],
          :teams => {
            :winning => [],
            :losing => []
          }
          })
  
        match = @matches[match_key]

        [[match[:teams][:winning], eog['body']['teamPlayerParticipantStats']['list']['source']],
         [match[:teams][:losing], eog['body']['otherTeamPlayerParticipantStats']['list']['source']]].each do |team, players|
            players.each do |player|
              new_player = {
                :locale => @locale,
                :summoner_name => player['summonerName'],
                :elo => player['elo'],
                :level => player['level'],
                :wins => player['wins'],
                :losses => player['losses'],
                :leaves => player['leaves'],
                :profile_icon_id => player['profileIconId'],
                :last_game_timestamp => eog['timestamp']
              }
        
              
              player_record = @players[player['summonerName']]
        
              if player_record
                player_record.merge!(new_player) unless (player_record[:last_game_timestamp] > new_player[:last_game_timestamp])
              else
                @players[player['summonerName']] = new_player.clone
              end
        
              @players[player['summonerName']][:matches] ||= []
              @players[player['summonerName']][:matches].push @locale + eog['body']['gameId']
        
              # Match-specific attributes
              new_player.merge!({
                :skin_name => player['skinName'],
                :statistics => {},
                :items => []
              })
        
              player['statistics']['list']['source'].each do |s|
                new_player[:statistics][s['statTypeId']] = s['value']
              end
        
              team.push(new_player)
            end
    
        end
      end

      # Items
      if !finding_items and message.match 'Found end of game item :'
        finding_items = true
      end
  
      if finding_items        
        if message.match 'Found end of game item'
          item = message.match 'Found end of game item : \d+ , (\d+)'     
          items.push item[1]
    
        elsif message.match 'ENDOFGAME: Player: '
    
          player_name = (message.match 'Player: (.+) has items')[1]
    
          existing_player = nil
          match[:teams][:winning].each do |p|
            existing_player = p if p[:summoner_name] == player_name
          end
    
          match[:teams][:losing].each do |p|
            existing_player = p if p[:summoner_name] == player_name
          end
    
          existing_player[:items] = items if existing_player

          items = [] # Clear the item queue now that we're done for this player
        end
  
        # Stop looking for items when we reach the end
        finding_items = false if !message.match 'EndOfGameStatsController'

      end
    end


    # Remove invalid matches  
    @matches = @matches.reject { |match| !@matches[match].has_key?(:teams) }

    {
      :matches => @matches,
      :players => @players
    }
  end
end