require 'time'
require 'securerandom'
require_relative '../test_management'
http = nil
describe 'Auth Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'create token' do
    it 'create new token' do
      response = InviteTokenFunctions.create_new_invite_token(http)
      parsed_body = JSON.parse(response.body)['invite_data']
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['invite_data']['token'].size).not_to be_nil
      expect(parsed_body['created_at'].size).not_to be_nil
      expect(parsed_body['expiration_data'].size).not_to be_nil
      expect(Time.parse(parsed_body['expiration_data']) - Time.parse(parsed_body['created_at'])).to eq(600)
    end

    it 'get user invite | before invite create' do
      response = InviteTokenFunctions.get_invite(http)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['invite_data']).to be_nil
    end

    it 'get user invite | after invite create' do
      InviteTokenFunctions.create_new_invite_token(http)
      response = InviteTokenFunctions.get_invite(http)
      parsed_body = JSON.parse(response.body)['invite_data']
      expect(response.code).to eq('200')
      expect(Time.parse(parsed_body['expiration_data']) - Time.parse(parsed_body['created_at'])).to eq(600)
      expect(parsed_body['token']).not_to be_nil
    end
  end

  describe 'check_link_validation | valid' do
    it 'check_link_validation | valid_link' do
      InviteTokenFunctions.create_new_invite_token(http)
      response = InviteTokenFunctions.get_invite(http)
      token = JSON.parse(response.body)['invite_data']['token']
      response = InviteTokenFunctions.check_link_validation(http, token)
      parsed_body = JSON.parse(response.body)
      expect(response.code).to eq('200')
      expect(parsed_body['validation']).to be_truthy
      expect(parsed_body['errors'].empty?).to be_truthy
    end

    it 'check_link_validation | not valid' do
      response = InviteTokenFunctions.check_link_validation(http, SecureRandom.hex)
      parsed_body = JSON.parse(response.body)
      expect(response.code).to eq('200')
      expect(parsed_body['validation']).to be_falsey
      expect(parsed_body['errors'].first).to eq('token_not_found')
    end
  end

  describe 'registration by invite' do
    it 'registration by invite | true link' do
      email = 10.times.map { StaticData::ALPHABET.sample }.join + '@g.com'
      password = 10.times.map { StaticData::ALPHABET.sample }.join
      response = InviteTokenFunctions.create_new_invite_token(http)
      parsed_body = JSON.parse(response.body)['invite_data']['token']
      http_helper = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
      result = http_helper.request(AuthFunctions.create_new_account(email: email,
                                                                    password: password,
                                                                    invite: parsed_body)[0])
      token = AuthFunctions.create_user_and_get_token(email, password)
      expect(token.nil?).to be_falsey
    end
  end
end