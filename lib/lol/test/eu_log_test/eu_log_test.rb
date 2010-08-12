require '../../lol'
require 'pp'

File.open('LolClient.20100710.232530.log') do |f|
  contents = LOL.parse_file(f.read())
  pp contents
end