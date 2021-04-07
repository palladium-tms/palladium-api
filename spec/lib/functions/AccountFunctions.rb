require 'net/http'
require 'json'
require_relative '../../../spec/lib/ObjectWrap/http'
require_relative '../User'
require 'json'

module AccountFunctions
  def self.create(email = Faker::Internet.email, password = Faker::Lorem.characters(number: 7), invite = nil)
    params = {user_data: {email: email, password: password}}
    params[:user_data][:invite] = invite if invite
    Http.new.post_request('/public/registration', params)
  end

  def self.create_and_parse(email = Faker::Internet.email, password = Faker::Lorem.characters(number: 7), invite = nil)
    response = AccountFunctions.create(email, password, invite)
    if JSON.parse(response.body)['errors'].empty?
      User.new(email: email, password: password)
    else
      raise 'User creation error', response.body
    end
  end
end
