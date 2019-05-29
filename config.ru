# frozen_string_literal: true

require 'sinatra'
require_relative 'server.rb'

run Rack::URLMap.new('/public' => Public, '/api' => Api)

raise 'JWT keys not found' if ENV['JWT_SECRET'].nil? || ENV['JWT_ISSUER'].nil?

configure do
  set :server, :puma
  set :root, File.dirname(__FILE__)
  enable :static
  enable :dump_errors
  set :show_exceptions, false # uncomment for testing or production
  set :environment, ENV['RACK_ENV']
end
