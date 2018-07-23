require_relative '../../../spec/data/static_data'
require 'net/http'
require_relative '../../tests/test_management'
class Http
  attr_accessor :http, :token

  def initialize(token: nil, address: StaticData::ADDRESS, port: StaticData::PORT)
    @http = Net::HTTP.new(address, port)
    @token = token
  end

  def random_name
    ('a'..'z').to_a.sample(30).join
  end

  def post_request(path, params = nil)
    request = Net::HTTP::Post.new(path, 'Authorization' => @token, 'Content-Type' => 'application/json')
    request.body = params.to_json if params
    http.request(request)
  end
end
