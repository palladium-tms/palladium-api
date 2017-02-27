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

run Sinatra::Application