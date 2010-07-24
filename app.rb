require 'sinatra'

require "sinatra/reloader" if development?
require 'pp' if development?

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
  #db = Mongo::Connection.new('flame.mongohq.com', 27078).db('loltistics')
  #auth = db.authenticate('amoeba', 'Ne2uMh')
  
  connection = Mongo::Connection.new('127.0.0.1', 27017)
  db = connection.db('loltistics')
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
  file = params[:file] ? params[:file][:tempfile] : env['rack.input']
  @result = LOL.parse_file(file.read)
  
  @result[:matches].each do |k, v|
    matches.insert(v) unless matches.find_one({'id' => k})
  end
  
  @result[:players].each do |k, v|
    existing_player = players.find_one('summoner_name' => v[:summoner_name])
  
    if existing_player
      players.save(existing_player) unless existing_player['last_game_timestamp'] < v[:last_game_timestamp]
    else
      players.insert(v)
    end
  end
  
  content_type :json
  
  {
    :success => true,
    :matches => @result[:matches].keys,
    :players => @result[:players].values.collect { |p| "#{p[:locale]}-#{p[:summoner_name]}" }
  }.to_json
end