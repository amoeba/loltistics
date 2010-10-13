require '../../lol'
require 'pp'

files = []
files << "LolClient.20100815.155553.log"
files << "LolClient.20100816.193705.log"

files.each do |filename|
  File.open(filename) do |f| 
    contents = LOL::XinZhaoParser.parse_file(f.read())
  
    pp contents[:ip]
  end
end