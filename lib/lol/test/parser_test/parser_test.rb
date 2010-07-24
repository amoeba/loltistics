require '../../lol'
require 'pp'

File.open('LolClient.20100722.220811.log') do |f|
  contents = LOL.parse_file(f.read())
  
  p = contents[:players].collect do |k, p|
    "#{p[:locale]}-#{k}"
  end
  
  pp p
end