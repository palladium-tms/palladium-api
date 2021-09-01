# frozen_string_literal: true

require 'sinatra'
require_relative 'server'

run Rack::URLMap.new('/public' => Public, '/api' => Api)
if Sinatra::Application.environment == :development || Sinatra::Application.environment == :test
  ENV['JWT_SECRET'] = "JWT_SECRET"
  ENV['JWT_ISSUER'] = "JWT_ISSUER"
end

raise 'JWT keys not found' if ENV['JWT_SECRET'].nil? || ENV['JWT_ISSUER'].nil?

raise 'JWT is to short' if Sinatra::Application.environment == :production && (ENV['JWT_SECRET'].size < 4 || ENV['JWT_ISSUER'].size < 4)

configure do
  set :server, :puma
  set :root, File.dirname(__FILE__)
  enable :static
  enable :dump_errors
  set :show_exceptions, false # uncomment for testing or production
  set :environment, ENV['RACK_ENV']
end
