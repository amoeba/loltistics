require 'sinatra'
require 'uri'
require 'mongo'
require 'haml'
require 'sass'
require 'json'

require './lib/lol/lol'

# Database
if ENV['MONGOHQ_URL']
  connection = Mongo::Connection.new(ENV['MONGOHQ_URL'], ENV['MONGOHQ_PORT'])
  db = connection.db(ENV['MONGOHQ_DB'])
  auth = db.authenticate(ENV['MONGOHQ_USER'], ENV['MONGOHQ_PASSWORD'])
else
  #connection = Mongo::Connection.new('flame.mongohq.com', 27074)
  connection = Mongo::Connection.new('localhost', 27017)
  db = connection.db('loltistics-test')
  #auth = db.authenticate('amoeba-test', 'amoeba-test')
end

if db
  matches = db.collection('matches')
  players = db.collection('players')
  logs = db.collection('logs')
end

if development?
  matches.remove()
  players.remove()
  logs.remove()
end

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
  
  @winning_team = @match['players'].select { |p| p['team_id'] == '100' }
  @losing_team = @match['players'].select { |p| p['team_id'] == '200' }
  
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
  
  @result[:players].each do |name, player|
    existing_player = players.find_one({:summoner_name => name})

    if existing_player
      if existing_player['last_game_timestamp'].to_i < player[:last_game_timestamp].to_i
        existing_player.merge!(player)
      end
    
      # Add matches to the Player
      existing_player['matches'] += player[:matches]
      existing_player['matches'].uniq!
      
      players.save(existing_player)
    else
      players.insert(player)
    end
  end
  
  matches_found = @result[:matches].keys
  players_found = @result[:players].collect { |name, player| "#{player[:locale]}-#{name}" }
  
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