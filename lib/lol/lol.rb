dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'parser'
require 'constants'

module LOL
  def self.champion_name(skin_name)
    CHAMPIONS[skin_name] or skin_name
  end
end