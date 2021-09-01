# frozen_string_literal: true

require_relative '../test_management'
describe 'Auth Smoke' do
  describe 'registration' do
    it 'create new without token' do
      expect(AuthFunctions.create_new_account(Faker::Internet.email, Faker::Lorem.characters(number: 7)).code).to eq('200')
    end
  end

  describe 'authorization' do
    it 'user login' do
      response = AccountFunctions.create_and_parse.login
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)).to be_key('token')
    end

    it 'try login with incorrect user_data' do
      response = User.new(email: Faker::Internet.email, password: Faker::Lorem.characters(number: 7)).login
      expect(response.code).to eq('401')
      expect(response.body).to eq('{"errors":"User or password not correct"}')
    end

    it 'create user and get token' do
      @user = AccountFunctions.create_and_parse
      @user.login
      expect(@user.token).not_to be_nil
    end
  end
end
