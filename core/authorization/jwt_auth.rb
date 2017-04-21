class JwtAuth
  def initialize app
    @app = app
  end

  def call env
    if env['REQUEST_METHOD'] == 'OPTIONS'
      return [200, {'Access-Control-Allow-Origin' => '*', 'Access-Control-Allow-Headers' => 'Authorization'}, []]
    else
      begin
        options = {algorithm: 'HS256', iss: ENV['JWT_ISSUER']}
        payload, header = JWT.decode env['HTTP_AUTHORIZATION'], ENV['JWT_SECRET'], true, options
        env[:scopes] = payload['scopes']
        env[:user] = payload['user']
        @app.call env
      rescue JWT::DecodeError
        [401, {'Content-Type' => 'text/plain'}, ['A token must be passed.']]
      rescue JWT::ExpiredSignature
        [403, {'Content-Type' => 'text/plain'}, ['The token has expired.']]
      rescue JWT::InvalidIssuerError
        [403, {'Content-Type' => 'text/plain'}, ['The token does not have a valid issuer.']]
      rescue JWT::InvalidIatError
        [403, {'Content-Type' => 'text/plain'}, ['The token does not have a valid "issued at" time.']]
      end
    end
  end
end