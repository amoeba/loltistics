require '../../lol'
require 'pp'

File.open('LolClient.20100722.220811.log') do |f|
  contents = LOL.parse_file(f.read())
  pp contents
end