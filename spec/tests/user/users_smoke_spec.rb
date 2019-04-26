require_relative '../../tests/test_management'
describe 'Users Smoke' do
  before :each do
    @http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
  end

  describe 'Create user' do
    it 'check creating new suite after run created' do
      email = Faker::Internet.email
      password = Faker::Lorem.characters(7)
      user = AuthFunctions.create_new_account(email: email, password: password)
      result = @http.request(user[0])
      expect(JSON.parse(result.body)['email']).to eq(email)
    end
  end

  describe 'User Settings' do

    before :each do
      @http = Http.new(token: AuthFunctions.create_user_and_get_token)
    end

    it 'check getting user settings' do
      UserSetting.get_setting(@http)
      expect(JSON.parse(UserSetting.get_setting(@http).body)['timezone']).to eq('MSK')
    end
  end
end
