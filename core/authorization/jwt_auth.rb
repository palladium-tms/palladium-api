# frozen_string_literal: true

class JwtAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['REQUEST_METHOD'] == 'OPTIONS'
      [200, { 'Access-Control-Allow-Origin' => '*', 'Access-Control-Allow-Headers' => 'Authorization, Content-Type' }, []]
    else
      begin
        options = { algorithm: 'HS256', iss: ENV['JWT_ISSUER'] }
        payload, _header = JWT.decode env['HTTP_AUTHORIZATION'], ENV['JWT_SECRET'], true, options
        env[:scopes] = payload['scopes']
        env[:user] = payload['user']
        @app.call env
      rescue JWT::DecodeError
        [401, { 'Access-Control-Allow-Origin' => '*', 'Access-Control-Allow-Headers' => 'Authorization, Content-Type' }, ['A token must be passed.']]
      rescue JWT::ExpiredSignature
        [403, { 'Access-Control-Allow-Origin' => '*', 'Access-Control-Allow-Headers' => 'Authorization, Content-Type' }, ['The token has expired.']]
      rescue JWT::InvalidIssuerError
        [403, { 'Access-Control-Allow-Origin' => '*', 'Access-Control-Allow-Headers' => 'Authorization, Content-Type' }, ['The token does not have a valid issuer.']]
      rescue JWT::InvalidIatError
        [403, { 'Access-Control-Allow-Origin' => '*', 'Access-Control-Allow-Headers' => 'Authorization, Content-Type' }, ['The token does not have a valid "issued at" time.']]
      end
    end
  end
end
