require 'net/http'
require 'json'
class AuthFunctions
  # @param [Strung] email for account. If it empty - will be generate
  # @param [String] password  for account. Min size = 6 simbols. If it empty - will be generate
  # return array with request and product name [request, product_name]
  def self.create_new_account(email = nil, password = nil)
    email = 10.times.map { StaticData::ALPHABET.sample }.join + '@g.com' if email.nil?
    password = 7.times.map { StaticData::ALPHABET.sample }.join if password.nil?
    request = Net::HTTP::Post.new('/registration', 'Content-Type' => 'application/json')
    request.set_form_data({"user_data[email]": email, "user_data[password]": password})
    [request, { email: email, password: password }]
  end

  def self.login(user_data)
    request = Net::HTTP::Post.new('/login', 'Content-Type' => 'application/json')
    request.set_form_data({"user_data[email]": user_data[:email], "user_data[password]": user_data[:password]})
    request
  end


  def self.create_user_and_get_token(email = nil, password = nil)
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    email ||= 10.times.map { StaticData::ALPHABET.sample }.join + '@g.com'
    password ||= 7.times.map { StaticData::ALPHABET.sample }.join
    request = Net::HTTP::Post.new('/registration', 'Content-Type' => 'application/json')
    request.set_form_data({"user_data[email]": email, "user_data[password]": password})
    http.request(request)
    request = Net::HTTP::Post.new('/login', 'Content-Type' => 'application/json')
    request.set_form_data({"user_data[email]": email, "user_data[password]": password})
    JSON.parse(http.request(request).body)['token']
  end
end