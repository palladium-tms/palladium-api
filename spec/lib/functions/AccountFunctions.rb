# frozen_string_literal: true

require 'net/http'
require 'json'
require_relative '../../../spec/lib/ObjectWrap/http'
require_relative '../User'

module AccountFunctions
  def self.create(email = Faker::Internet.email, password = Faker::Lorem.characters(number: 7), invite = nil)
    params = { user_data: { email:, password: } }
    params[:user_data][:invite] = invite if invite
    Http.new.post_request('/public/registration', params)
  end

  def self.create_and_parse(email = Faker::Internet.email, password = Faker::Lorem.characters(number: 7), invite = nil)
    response = AccountFunctions.create(email, password, invite)
    return User.new(email:, password:) if JSON.parse(response.body)['errors'].empty?

    raise 'User creation error', response.body
  end
end
