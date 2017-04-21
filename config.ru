require 'sinatra'
require './server.rb'

# Sinatra::Application = Rack::Auth::Digest::MD5.new(Sinatra::Application) do |username|
#   # Return the password for the given user
#   {'john' => 'johnsecret'}[username]
# end
#
# Sinatra::Application.realm = 'Protected Area'
# Sinatra::Application.opaque = 'secretkey'
#

run Rack::URLMap.new({
                         '/' => Public,
                         '/api' => Api
                     })
configure {
  set :server, :puma
  set :root, File.dirname(__FILE__)
  enable :static
  enable :dump_errors
  set :show_exceptions, false # uncomment for testing or production
}
