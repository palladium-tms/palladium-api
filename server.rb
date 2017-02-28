require_relative 'management'
include Auth
configure {
  set :server, :puma
  set :root, File.dirname(__FILE__)
  enable :static
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
# endregion pages

# region auth
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
    {user_data: user_data, errors: 'login or password is uncorrect'}.to_json # used in 'check registration page loading' test
  end
end
# endregion auth

# region product
post '/product_new' do
  if access_available?
    product = Product.create_new(product_data)
    content_type :json
    status 200
    {'product': product.values, "errors": product.errors}.to_json
  else
    status 201
    {errors: 'login or password is uncorrect'}.to_json # used in 'check registration page loading' test
  end
end

get '/products' do
  if access_available?
    products = Product.all
    content_type :json
    status 200
    {'products': products.map{|current| current.values }}.to_json
  else
    status 201
    {errors: 'login or password is uncorrect'}.to_json # used in 'check registration page loading' test
  end
end

delete '/product_delete' do
  if access_available?
    result = Product.where(:id => product_data['id']).destroy
    content_type :json
    status 200
    {'product': product_data['id'],'product_deleted': result == 1 }.to_json
  else
    status 201
    {errors: 'login or password is uncorrect'}.to_json # used in 'check registration page loading' test
  end
end
# endregion product


def login_required
  if session[:user]
    return true
  else
    redirect '/login'
    return false
  end
end

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

def product_data
    params['product_data']
end

def access_available?
  auth_status = false
  if user_data_strong?
    auth_status = auth_success?(user_data)
  end
  !session[:user].nil? || auth_status
end

def user_data_strong?
  if params.key?('user_data')
    params['user_data'].key?('email') && params['user_data'].key?('password')
  else
    false
  end
end
