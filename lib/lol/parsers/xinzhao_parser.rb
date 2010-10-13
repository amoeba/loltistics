module LOL
  class XinZhaoParser < Parser
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
      @messages = content.split /^[\d\/]/
      @server, @matches, @players = nil, {}, {}
      match, match_key = nil, ''
      items, finding_items = [], false
      
      #Debugging IP gain
      @ip_gain = {}
      
      @messages.each do |message|
        # Server
        if @server.nil? and message.match 'loadProperties: host = '
          @server = (message.include?('beta.lol.riotgames.com')) ? 'US' : 'EU'
        end
      
        # GameDTO
        if message.match 'gameState = "TERMINATED"'
          dto = parse(message)
          match_key = @server + dto['body']['id']
  
          match_data = {
            :id => match_key,
            :map_id => dto['body']['mapId'],
            :creation_time => dto['body']['creationTime'],
            :game_type => dto['body']['gameType']
          }
        
          @matches[match_key] ||= {}
          @matches[match_key].merge!(match_data)
        end

        # EndOfGameStats
        if message.match 'EndOfGameStats\)#1'
        
          eog = parse(message)
          
          #Debugging IP
          @ip_gain.merge!({match_key => eog['body']['basePoints']})
          #END Debugging IP
          
          match_key = @server + eog['body']['gameId']
        
          # Older matches don't have this. Default to NORMAL
          queue_type = eog['body']['queueType'].nil? ? 'NORMAL' : eog['body']['queueType']

          match_data = {
            :queue_type => queue_type,
            :game_length => eog['body']['gameLength'],
            :game_type => eog['body']['gameType'],
            :ranked => eog['body']['ranked'],
            :players => []
          }
        
          # To find out which team won we need to look at ELO change
          # 2010/08/17: This method doesn't work any longer
          # team 100 is blue
          # team 200 is purple
          # teamPlayerParticipantStats always contains the uploader
          all_players = eog['body']['teamPlayerParticipantStats']['list']['source'] + eog['body']['otherTeamPlayerParticipantStats']['list']['source']
        
          all_players.each do |player|
            new_player = {
              :server => @server,
              :summoner_name => player['summonerName'],
              :level => player['level'],
              :profile_icon_id => player['profileIconId'],
              :last_game_timestamp => eog['timestamp'],
              :matches => {},
              :record => {},
              :elo => {}
            }
          
            match_player = {
              :server => @server,
              :summoner_name => player['summonerName'],
              :team_id => player['teamId'],
              :level => player['level'],
              :elo => player['elo'],
              :elo_change => player['eloChange'],
              :skin_name => player['skinName'],
              :statistics => {},
              :items => []
            }
          
            # Player Statistics
            player['statistics']['list']['source'].each do |s|
              match_player[:statistics][s['statTypeId']] = s['value']
            end
          
            existing_player = @players[player['summonerName']]
          
            if existing_player
              existing_matches = @players[player['summonerName']][:matches]
              existing_elo = @players[player['summonerName']][:elo]
              existing_record = @players[player['summonerName']][:record]
              existing_matches = @players[player['summonerName']][:matches]
            end
          
            if existing_player.nil? or existing_player[:last_game_timestamp].to_i < new_player[:last_game_timestamp].to_i
              @players[player['summonerName']] = new_player
            
              # Add or update the record
            
              # Older log files don't have a queueType in their EOGStats so we must have a fallback
              match_type = eog['body']['ranked'] =~ /true/ ? :ranked : :normal
            
              @players[player['summonerName']][:record] = existing_record if existing_record
              @players[player['summonerName']][:record].merge!(
                {
                  match_type => {
                    :wins => player['wins'],
                    :losses => player['losses'],
                    :leaves => player['leaves'],
                  }
                }
              )
            
              @players[player['summonerName']][:elo] = existing_elo if existing_elo
              if player['elo']
                @players[player['summonerName']][:elo].merge!(
                  {
                    queue_type => player['elo']
                  }
                )
              end
            end
          
            @players[player['summonerName']][:matches] = existing_matches if existing_matches
          
            # Only add Record and Matches for non-PRACTICE_GAMES
            if match_data[:game_type] != "PRACTICE_GAME"
              is_winner = player['eloChange'].to_i > 0
            
              @players[player['summonerName']][:matches].merge!(
                {
                  match_key => {
                    :winner => is_winner,
                    :skin_name => player['skinName'],
                    :game_length => eog['body']['gameLength'],
                    :time_started => eog['timestamp'],
                    :ranked => eog['body']['ranked'],
                    :elo => player['elo'],
                    :queue_type => queue_type
                  }
                }  
              )
            end
    
            match_data[:players].push(match_player)
          end
        
          @matches[match_key] ||= {}
          @matches[match_key].merge!(match_data)
        end

        # Items
        if !finding_items and message.include? 'Found end of game item :'
          finding_items = true
        end
  
        if finding_items        
          if message.include? 'Found end of game item'
            item = message.match 'Found end of game item : \d+ , (\d+)'     
            items.push item[1]
          elsif message.include? 'ENDOFGAME: Player: '
          
            player_name = (message.match 'Player: (.+) has items')[1]
    
            existing_player = nil
          
            match = @matches[match_key]
            match[:players].each do |p|
              existing_player = p if p[:summoner_name] == player_name
            end
    
            existing_player[:items] = items if existing_player

            items = [] # Clear the item queue now that we're done for this player
          end
  
          # Stop looking for items when we go beyond the item messages
          finding_items = false if !message.include? 'EndOfGameStatsController'
        end
      end

      # Remove invalid matches  
      # Remove practice games
      @matches = @matches.reject do |match_key, match|
        !match.has_key?(:game_length) or match[:game_type] == "PRACTICE_GAME"
      end
    
      {
        :matches => @matches,
        :players => @players,
        :ip => @ip_gain
      }
    end
  end
end