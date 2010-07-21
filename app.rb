require 'sinatra'
require 'uri'
require 'mongo'
require 'haml'
require 'sass'

require './lib/lol/lol'

# MongoHQ
if ENV['MONGOHQ_URL']
  # We're on Heroku and should use MongoHQ
  uri = URI.parse(ENV['MONGOHQ_URL'])
  connection = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  db = connection.db(uri.path.gsub(/^\//, ''))
  
  #db = Mongo::Connection.new('flame.mongohq.com', 27078).db('loltistics')
  #auth = db.authenticate('amoeba', 'Ne2uMh')
else
  connection = Mongo::Connection.new('127.0.0.1', 27017)
  db = connection.db('loltistics')
end

if db
  matches = db.collection('matches')
  players = db.collection('players')
end

set :haml, {:format => :html5 }

get '/stylesheets/loltistics.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :loltistics
end
  
get '/' do
  haml :index
end

get '/matches' do
  @matches = matches.find()
  
  haml :matches
end

get '/matches/:id' do |id|
  @match = matches.find_one('id' => id)
  
  haml :match
end

get '/players/:name' do |name|
  @player = players.find_one('summoner_name' => name)
  
  haml :player
end

get '/upload' do
  haml :upload
end

post '/upload' do
  @result = LOL.parse_file(params[:file][:tempfile].read)
  
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

  haml :result
end