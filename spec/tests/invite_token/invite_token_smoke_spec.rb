require 'time'
require 'securerandom'
require_relative '../test_management'
describe 'Auth Smoke' do
  before do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'create token' do
    it 'create new token' do
      response = @user.create_new_invite_token
      parsed_body = JSON.parse(response.body)['invite_data']
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['invite_data']['token'].size).not_to be_nil
      expect(parsed_body['created_at'].size).not_to be_nil
      expect(parsed_body['expiration_data'].size).not_to be_nil
      expect(Time.parse(parsed_body['expiration_data']) - Time.parse(parsed_body['created_at'])).to eq(600)
    end

    it 'get user invite | before invite create' do
      response = @user.get_invite
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['invite_data']).to be_nil
    end

    it 'get user invite | after invite create' do
      @user.create_new_invite_token
      response = @user.get_invite
      parsed_body = JSON.parse(response.body)['invite_data']
      expect(response.code).to eq('200')
      expect(Time.parse(parsed_body['expiration_data']) - Time.parse(parsed_body['created_at'])).to eq(600)
      expect(parsed_body['token']).not_to be_nil
    end
  end

  describe 'check_link_validation | valid' do
    it 'check_link_validation | valid_link' do
      @user.create_new_invite_token
      response = @user.get_invite
      token = JSON.parse(response.body)['invite_data']['token']
      response = @user.check_link_validation(token)
      parsed_body = JSON.parse(response.body)
      expect(response.code).to eq('200')
      expect(parsed_body['validation']).to be_truthy
      expect(parsed_body['errors']).to be_empty
    end

    it 'check_link_validation | not valid' do
      response = @user.check_link_validation(SecureRandom.hex)
      parsed_body = JSON.parse(response.body)
      expect(response.code).to eq('200')
      expect(parsed_body['validation']).to be_falsey
      expect(parsed_body['errors'].first).to eq('token_not_found')
    end
  end

  describe 'registration by invite' do
    it 'registration by invite | true link' do
      response = @user.create_new_invite_token
      token = JSON.parse(response.body)['invite_data']['token']
      new_user = AccountFunctions.create_and_parse(Faker::Internet.email, Faker::Lorem.characters(number: 7), token)
      new_user.login
      expect(new_user.token).not_to be_nil
    end
  end
end
