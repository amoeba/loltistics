require 'sinatra'
require 'mongo'
require 'haml'
require 'sass'

set :haml, {:format => :html5 }

get '/stylesheets/loltistics.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :loltistics
end
  
get '/' do
  haml :index
end

get '/match/:id' do |match|
  @match = match
  
  haml :match
end

get '/player/:name' do |player|
  @player = player
  
  haml :player
end