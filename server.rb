require_relative 'management'
include Auth
configure {
  set :server, :puma
  set :root, File.dirname(__FILE__)
  enable :static
  enable :logging
  enable :dump_errors
  set :sessions, key: 'N&wedhSDF',
      domain: "localhost",
      path: '/',
      expire_after: 14400,
      secret: '*&(^B234'
  set :show_exceptions, false # uncomment for testing or production
}

# region pages start
get '/' do
  login_required
  erb :index
end

get '/login' do
  erb :login
end

get '/registration' do
  erb :registration
end

not_found do
  'This is nowhere to be found.'
end

error do
  'Sorry there was a nasty error - ' + env['sinatra.error'].message
end
# region pages end

get '/logout' do
  session[:user] = nil
  redirect '/'
end

post '/registration' do
    new_user = User.create_new(user_data)
    begin
      new_user.save if new_user.errors.empty?
      rescue
    end
    if new_user.errors.empty?
      session[:user] = user_data['email']
      status 200
    else
      status 201
      content_type :json
      new_user.errors.to_json
    end
end

post '/login' do
  if auth_success?(user_data)
    session[:user] = user_data['email']
    status 200
  else
    status 201
    content_type :json
    {error: 'login or password is uncorrect'}.to_json # used in 'check registration page loading' test
  end
end

# Protect pages
def login_required
  if session[:user]
    return true
  else
    redirect '/login'
    return false
  end
end

# Get the username of the logged in user
def current_user
  if session[:user]
    session[:user]
  end
end

def user_data
  begin
    params['user_data']
  rescue Exception
    error
  end
end
