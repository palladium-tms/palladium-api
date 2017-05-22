require_relative 'management'
class Api < Sinatra::Base
  include Auth
  register Sinatra::CrossOrigin
  use JwtAuth

  def initialize
    super
  end

  before do
    content_type :json
    cross_origin
  end

  get '/products' do
    process_request request, 'products' do |_req, _username|
      { products: Product.all.map(&:values) }.to_json
    end
  end

  post '/product_new' do
    process_request request, 'product_new' do |_req, _username|
      product = Product.create_new(params)
      {'product' => product.values, "errors" => product.errors}.to_json
    end
  end

  def process_request(req, scope)
    scopes, user = req.env.values_at :scopes, :user
    username = user['email']
    if scopes.include?(scope) && User.find(email: username).exists?
      yield req, username
    else
      halt 403
    end
  end
end

class Public < Sinatra::Base
  include Auth
  register Sinatra::CrossOrigin

  post '/login' do
    cross_origin
    if auth_success?(user_data)
      content_type :json
      { token: token(user_data['email']) }.to_json
    else
      halt 401
    end
  end


  get '/login' do
    erb :login
  end

  get '/registration' do
    erb :registration
  end

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

  def user_data
    params['user_data']
  rescue StandardError => error
    error
  end

  def token(email)
    JWT.encode payload(email), ENV['JWT_SECRET'], 'HS256'
  end

  def payload(email)
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      scopes: %w(products product_new),
      user: {
        email: email
      }
    }
  end
end
