require_relative '../../../spec/data/static_data'
require 'net/http'
class Http
  attr_accessor :http, :token

  def initialize(token: nil, address: StaticData::ADDRESS, port: StaticData::PORT)
    @http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    @token = token
  end

  def random_name
    30.times.map { StaticData::ALPHABET.sample }.join
  end

  def post_request(path, params= nil)
    request = Net::HTTP::Post.new(path, 'Authorization' => @token)
    request.set_form_data(params) if params
    http.request(request)
  end
end