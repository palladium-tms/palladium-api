# frozen_string_literal: true

# Module to work with JWT data
module JwtHelper
  # Generate a JWT token
  # @param [String] data the data to encode in the JWT
  # @return [String] result of encoding
  def token(data)
    JWT.encode(payload(data), ENV.fetch('JWT_SECRET', ''), 'HS256')
  end
end
