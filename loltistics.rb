require 'sinatra/base'
require 'mongo'
require 'haml'
require 'sass'
require 'json'
require 'pony'

require 'rack-flash'

require './lib/lol/lol'
  
class Loltistics < Sinatra::Base
  set :haml, {:format => :html5 }
  set :static, :true
  set :public, 'public'
  
  enable :sessions
  use Rack::Flash
  
  configure do
    if ENV['MONGOHQ_URL']
      connection = Mongo::Connection.new(ENV['MONGOHQ_URL'], ENV['MONGOHQ_PORT'])
      db = connection.db(ENV['MONGOHQ_DB'])
      auth = db.authenticate(ENV['MONGOHQ_USER'], ENV['MONGOHQ_PASSWORD'])
    else
      connection = Mongo::Connection.new('localhost', 27017)
      db = connection.db('loltistics-test')
    end
    
    @@matches_collection = db.collection('matches')
    @@players_collection = db.collection('players')
    @@logs_collection = db.collection('logs')
    
    # Clean
    @@matches_collection.remove
    @@players_collection.remove
    @@logs_collection.remove
  end

  # Error Pages

  class PlayerNotFound < StandardError; end
  class MatchNotFound < StandardError; end

  error PlayerNotFound do
    haml :'404', :locals => { :message => 'Player not found' }
  end

  error MatchNotFound do
    haml :'404', :locals => { :message => 'Match not found' }
  end

  
  # Helpers

  helpers do
    def process_uploaded_file(filename, content, save)
      time_started = Time.now
      result = LOL::XinZhaoParser.parse_file(content)
      
      require 'pp'
      pp result
      
      if save
        result[:matches].each do |match_key, match|
          @@matches_collection.update({ 'id' => match[:id] }, match, { :upsert => true })
        end
       
        result[:players].each do |name, player|
          existing_player = @@players_collection.find_one({:summoner_name => name})

          if existing_player
            if existing_player['last_game_timestamp'].to_i <= player[:last_game_timestamp].to_i
              existing_player.merge!(player)
            end
    
            # Add matches to the Player
            existing_player['matches'].merge!(player[:matches])
          
            @@players_collection.save(existing_player)
          else
            @@players_collection.insert(player)
          end
        end
      end
      
      matches_found = result[:matches].keys
      players_found = result[:players].collect { |name, player| "#{player[:server]}-#{name}" }
      
      time_to_parse = Time.now - time_started
      
      @@logs_collection.insert({
        :filename => filename,
        :parsed_at => time_started,
        :parse_time => time_to_parse,
        :matches_found => matches_found,
        :players_found => players_found
      })
    
      {
        :matches => matches_found,
        :players => players_found
      }
    end
    
    def pretty_queue_type(type)
      type.split('_').each(&:capitalize!).join(' ')
    end
  end
  
  
  # Routes
  get '/stylesheets/loltistics.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :loltistics
  end
  
  get '/' do
    flash[:notice] = "The uploader is down due to some changes to to the logfiles that came with the Galio patch."
    haml :index
  end

  get '/matches' do
    #@matches_normal = @matches.select { |m| m['queue_type'] == 'NORMAL'}
    #@matches_premade_3v3 = @matches.select { |m| m['queue_type'] == 'RANKED_PREMADE_3v3'}
    #@matches_solo_5v5 = @matches.select { |m| m['queue_type'] == 'RANKED_SOLO_5v5'}
    #@matches_premade_5v5 = @matches.select { |m| m['queue_type'] == 'RANKED_PREMADE_5v5'}
    
    @matches_normal = @@matches_collection.find({:queue_type => 'NORMAL'}).limit(10)
    @matches_premade_3v3 = @@matches_collection.find({:queue_type => 'RANKED_PREMADE_3v3'}).limit(10)
    @matches_solo_5v5 = @@matches_collection.find({:queue_type => 'RANKED_SOLO_5v5'}).limit(10)
    @matches_premade_5v5 = @@matches_collection.find({:queue_type => 'RANKED_PREMADE_5v5'}).limit(10)
  
    haml :matches
  end

  get '/matches/:id' do |id|
    @match = @@matches_collection.find_one({'id' => id})
    raise MatchNotFound if @match.nil?
  
    @winning_team = @match['players'].select { |p| p['elo_change'].to_i > 0 }
    @losing_team = @match['players'].select { |p| p['elo_change'].to_i < 0 }
  
    haml :match
  end

  get '/players' do
    @players = @@players_collection.find().limit(50).sort([['summoner_name',1]])
  
    haml :players
  end

  get %r{/players/([EUS]{2})-(.+)} do |server, name|
    @player = @@players_collection.find_one({'server' => server, 'summoner_name' => name})
    raise PlayerNotFound if @player.nil?
    
    if @player['matches']
      
      @player['matches'] = @player['matches'].sort_by { |k, m| m['time_started'] }.reverse!
      
      @normal_matches = @player['matches'].select { |k, m| m['queue_type'] =~ /NORMAL/}
      @premade_3v3_matches = @player['matches'].select { |k, m| m['queue_type'] =~ /RANKED_PREMADE_3v3/}
      @solo_5v5_matches = @player['matches'].select { |k, m| m['queue_type'] =~ /RANKED_SOLO_5v5/}
      @premade_5v5_matches = @player['matches'].select { |k, m| m['queue_type'] =~ /RANKED_PREMADE_5v5/}
    end
    
    haml :player
  end

  get '/logs' do
    @logs = @@logs_collection.find().limit(50).sort(['parsed_at', :descending])
  
    haml :logs
  end
  
  get '/feedback' do
    haml :feedback
  end

  post '/feedback' do
    from = params['feedback-from'] or 'nobody@loltistics.com'
    message = params['feedback-message'] or 'No message content'

    Pony.mail({
      :to => 'petridish+loltistics@gmail.com', 
      :from => from,
      :subject => 'LoLtistics Feedback',
      :body => message,
      :via => :smtp, 
      :via_options => {
        :address              => 'smtp.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => ENV['GMAIL_USERNAME'],
        :password             => ENV['GMAIL_PASSWORD'],
        :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
        :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
      }
    })
  
    haml '%p Your message has been sent'
  end

  get '/upload' do
    haml :upload
  end

  post '/upload' do
    filename = params['qqfile'] or params['file'][:filename]
    file = params['file'] ? params[:file][:tempfile].read : env['rack.input'].read
  
    @result = process_uploaded_file(filename, file, true)
    
    if params['qqfile']
      content_type :json
  
      {
        :success => true,
        :matches => @result[:matches],
        :players => @result[:players]
      }.to_json
    else
      haml :result
    end
  end
end
