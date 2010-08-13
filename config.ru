begin
  require 'bundler'
rescue LoadError
  require 'rubygems'
  require 'bundler'
end

Bundler.setup

require './loltistics'
run Loltistics.new