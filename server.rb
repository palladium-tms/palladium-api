require 'sinatra'
configure { set :server, :puma } # use puma like default web server
get '/' do
  code = "<%= Time.now %>"
  erb code
end

not_found do
  'This is nowhere to be found.'
end

error do
  'Sorry there was a nasty error - ' + env['sinatra.error'].message
end