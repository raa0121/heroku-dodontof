require 'bundler/setup'

Bundler.require
require './web'
require './MsgPackParamsParser'
use Rack::MsgpackParamsParser
run DodontoFApp
