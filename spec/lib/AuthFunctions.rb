require 'net/http'
require 'json'
require_relative '../../spec/lib/ObjectWrap/http'
class AuthFunctions
  # @param [Strung] email for account. If it empty - will be generate
  # @param [String] password  for account. Min size = 6 simbols. If it empty - will be generate
  # return array with request and product name [request, product_name]
  def self.create_new_account(option = {})
    option[:email] ||= 10.times.map { StaticData::ALPHABET.sample }.join + '@g.com'
    option[:password] ||= 7.times.map { StaticData::ALPHABET.sample }.join
    request = Net::HTTP::Post.new('/registration', 'Content-Type' => 'application/json')
    params = {'user_data[email]': option[:email], 'user_data[password]': option[:password]}
    params.merge!(invite: option[:invite]) unless option[:invite].nil?
    request.set_form_data(params)
    [request, { email: option[:email], password: option[:password] }]
  end

  def self.login(user_data)
    request = Net::HTTP::Post.new('/login', 'Content-Type' => 'application/json')
    request.set_form_data({'user_data[email]': user_data[:email], 'user_data[password]': user_data[:password]})
    request
  end

  def self.create_user_and_get_token(email = nil, password = nil)
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    email ||= 10.times.map { StaticData::ALPHABET.sample }.join + '@g.com'
    password ||= 7.times.map { StaticData::ALPHABET.sample }.join
    request = Net::HTTP::Post.new('/registration', 'Content-Type' => 'application/json')
    request.set_form_data({'user_data[email]': email, 'user_data[password]': password})
    http.request(request)
    AuthFunctions.get_token(email, password)
  end

  def self.get_token(email, password)
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    request = Net::HTTP::Post.new('/login', 'Content-Type' => 'application/json')
    request.set_form_data({'user_data[email]': email, 'user_data[password]': password})
    JSON.parse(http.request(request).body)['token']
  end
end