require 'sinatra'
require_relative 'server.rb'

run Rack::URLMap.new('/' => Public,
                     '/api' => Api)

configure do
  set :server, :puma
  set :root, File.dirname(__FILE__)
  enable :static
  enable :dump_errors
  set :show_exceptions, false # uncomment for testing or production
  set :environment, ENV['RACK_ENV']
end
