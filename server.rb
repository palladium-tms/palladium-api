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
    process_request request, 'products' do |req, username|
      {'products': Product.all.map { |current| current.values }}.to_json
    end
  end

  def process_request req, scope
    scopes, user = req.env.values_at :scopes, :user
    username = user['email']
    if scopes.include?(scope) && User.find(:email => username).exists?
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
      {token: token(user_data['email'])}.to_json
    else
      halt 401
    end
  end

  def user_data
    begin
      params['user_data']
    rescue Exception
      error
    end
  end

  def token(email)
    JWT.encode payload(email), ENV['JWT_SECRET'], 'HS256'
  end

  def payload(email)
    {
        exp: Time.now.to_i + 60 * 60,
        iat: Time.now.to_i,
        iss: ENV['JWT_ISSUER'],
        scopes: ['products'],
        user: {
            email: email
        }
    }
  end
end
