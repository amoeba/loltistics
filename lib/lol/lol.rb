dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'constants'

Dir[File.dirname(__FILE__) + '/parsers/*.rb'].each {|file| require file }

module LOL
  def self.champion_name(skin_name)
    CHAMPIONS[skin_name] or skin_name
  end
  
  def self.map_name(map_id)
    MAPS[map_id] or map_id
  end
  
  def self.item_name(item_id)
    ITEMS[item_id] or item_id
  end
end