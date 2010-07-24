require 'mongo'

connection = Mongo::Connection.new('flame.mongohq.com', 27074)
db = connection.db('loltistics-test')
auth = db.authenticate('amoeba', 'Ne2uMh')

matches = db.collection('matches')
players = db.collection('players')

matches.remove()
players.remove()

matches.insert({
  :id => 'US1234'
})

players.insert({
  :summoner_name => 'Petridish',
  :matches => []
})

puts 'before'
matches.find().each { |m| puts m }
players.find().each { |p| puts p }

match_ref = matches.find_one({:id => 'US1234' })
player_ref = players.find_one({ :summoner_name => 'Petridish' })

player_ref['matches'].push(match_ref)
player_ref.save

puts 'after'
matches.find().each { |m| puts m }
players.find().each { |p| puts p }