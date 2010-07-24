require 'sinatra'
require 'uri'
require 'mongo'
require 'haml'
require 'sass'
require 'json'

require './lib/lol/lol'

# Database
if ENV['MONGOHQ_URL']
  #uri = URI.parse(ENV['MONGOHQ_URL'])
  #connection = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  #db = connection.db(uri.path.gsub(/^\//, ''))
  
  connection = Mongo::Connection.new(ENV['MONGOHQ_URL'], ENV['MONGOHQ_PORT'])
  db = connection.db(ENV['MONGOHQ_DB'])
  auth = db.authenticate(ENV['MONGOHQ_USER'], ENV['MONGOHQ_PASSWORD'])
else
  connection = Mongo::Connection.new('flame.mongohq.com', 27074)
  db = connection.db('loltistics-test')
  auth = db.authenticate('amoeba', 'Ne2uMh')
  
  #connection = Mongo::Connection.new('127.0.0.1', 27017)
  #db = connection.db('loltistics')
end

if db
  matches = db.collection('matches')
  players = db.collection('players')
  logs = db.collection('logs')
end

matches.remove()
players.remove()
logs.remove()

# Configuration
set :haml, {:format => :html5 }

# Error Pages

class PlayerNotFound < StandardError; end
class MatchNotFound < StandardError; end

error PlayerNotFound do
  haml :'404', :locals => { :message => 'Player not found' }
end

error MatchNotFound do
  haml :'404', :locals => { :message => 'Match not found' }
end

# Routes
get '/stylesheets/loltistics.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :loltistics
end
  
get '/' do
  haml :index
end

get '/matches' do
  @matches = matches.find().sort([['id', 1]])
  
  haml :matches
end

get '/matches/:id' do |id|
  @match = matches.find_one('id' => id)
  raise MatchNotFound if @match.nil?
  
  haml :match
end

get '/players' do
  @players = players.find().sort([['summoner_name',1]])
  
  haml :players
end

get %r{/players/([EUS]{2})-(.+)} do |locale, name|
  @player = players.find_one({'locale' => locale, 'summoner_name' => name})
  raise PlayerNotFound if @player.nil?

  haml :player
end

get '/logs' do
  @logs = logs.find()
  
  haml :logs
end

get '/upload' do
  haml :upload
end

post '/upload' do
  filename = params['qqfile'] or params['file']
  file = params[:file] ? params[:file][:tempfile] : env['rack.input']
  
  time_started = Time.now
  @result = LOL.parse_file(file.read)
  time_to_parse = Time.now - time_started
  
  @result[:matches].each do |match_key, match|
    matches.insert(match) unless matches.find_one({'id' => match_key})
  end
  
  @result[:players].each do |player|
    existing_player = players.find_one({:summoner_name => player[:summoner_name]})
  
    if existing_player
      if existing_player['last_game_timestamp'].to_i < player[:last_game_timestamp].to_i
        players.save(existing_player.merge!(player))
      end
    else
      players.insert(player)
    end
    
    # Add matches to the Player
    player_match = matches.find_one({'id' => player[:last_match_key]})
    
    if player_match
      puts "Finding and modifying"
      players.find_and_modify({
        :query => { :summoner_name => player[:summoner_name] }, 
        :update => { 
          '$push' => { :matches => player_match}
        }
      })
    end
  end
  
  matches_found = @result[:matches].keys
  players_found = @result[:players].collect { |p| "#{p[:locale]}-#{p[:summoner_name]}" }
  
  logs.insert({
    :filename => filename,
    :parsed_at => time_started,
    :parse_time => time_to_parse,
    :matches_found => matches_found,
    :players_found => players_found,
    :reduced_file => @result[:reduced_file]
  })
  
  content_type :json
  
  {
    :success => true,
    :matches => matches_found,
    :players => players_found
  }.to_json
end