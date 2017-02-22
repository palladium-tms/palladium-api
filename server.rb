require 'sinatra'
configure {
  set :server, :puma
  set :root, File.dirname(__FILE__)
  enable :static
  enable :logging
  enable :dump_errors
}

get '/' do
  erb :index
end

not_found do
  'This is nowhere to be found.'
end

error do
  'Sorry there was a nasty error - ' + env['sinatra.error'].message
end