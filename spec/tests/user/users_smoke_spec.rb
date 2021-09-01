require_relative '../../tests/test_management'
describe 'Users Smoke' do
  describe 'Create user' do
    it 'create new user' do
      email = Faker::Internet.email
      password = Faker::Lorem.characters(number: 7)
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
      expect(JSON.parse(response.body)['timezone']).not_to be_nil
    end

    it 'check change timezone' do
      timezone = "#{Faker::Bank.name}: +0#{rand(10)}:00"
      response_setting = @user.update_user_setting(timezone: timezone)
      expect(response_setting.code).to eq('200')
      response_getting = @user.get_setting
      expect(response_getting.code).to eq('200')
      expect(JSON.parse(response_getting.body)['timezone']).to eq(timezone)
    end
  end
end
