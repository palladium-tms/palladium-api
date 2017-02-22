require 'sinatra/base'
get '/' do
  code = "<%= Time.now %>"
  erb code
end