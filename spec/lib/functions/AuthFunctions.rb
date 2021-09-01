require 'net/http'
require 'json'
require_relative '../../../spec/lib/ObjectWrap/http'
class AuthFunctions
  # @param [Strung] email for account. If it empty - will be generate
  # @param [String] password  for account. Min size = 6 simbols. If it empty - will be generate
  # return array with request and product name [request, product_name]
  def self.create_new_account(email = Faker::Internet.email, password = Faker::Lorem.characters(number: 7))
    Http.new.post_request('/public/registration', { user_data: { email: email, password: password } })
  end

  def self.login(user_data)
    request = Net::HTTP::Post.new('/public/login', 'Content-Type' => 'application/json')
    request.set_form_data({ 'user_data[email]': user_data[:email], 'user_data[password]': user_data[:password] })
    request
  end

  def self.create_user_and_get_token(email = nil, password = nil)
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    email ||= Faker::Internet.email
    password ||= Faker::Lorem.characters(number: 7)
    request = Net::HTTP::Post.new('/public/registration', 'Content-Type' => 'application/json')
    request.set_form_data({ 'user_data[email]': email, 'user_data[password]': password })
    http.request(request)
    AuthFunctions.get_token(email, password)
  end

  def self.get_token(email, password)
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    request = Net::HTTP::Post.new('/public/login', 'Content-Type' => 'application/json')
    request.set_form_data({ 'user_data[email]': email, 'user_data[password]': password })
    JSON.parse(http.request(request).body)['token']
  end
end
