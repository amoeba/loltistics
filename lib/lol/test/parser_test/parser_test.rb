require '../../lol'
require 'pp'

#File.open('LolClient.20100722.220811.log') do |f|
File.open('failing_log.log') do |f| 
  contents = LOL::XinZhaoParser.parse_file(f.read())
  pp contents
end