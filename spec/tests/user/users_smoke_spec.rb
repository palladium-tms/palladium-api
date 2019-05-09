require_relative '../../tests/test_management'
describe 'Users Smoke' do
  describe 'Create user' do
    it 'create new user' do
      email = Faker::Internet.email
      password = Faker::Lorem.characters(7)
      response = AccountFunctions.create(email, password)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['email']).to eq(email)
    end
  end

  describe 'User Settings' do

    before :each do
      @user = AccountFunctions.create_and_parse
      @user.login
    end

    it 'check getting user settings' do
      response = @user.get_setting
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['timezone']).to eq('MSK')
    end
  end
end
