require_relative '../../tests/test_management'
http, account = nil
describe 'Result Smoke' do
  before :each do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    request = AuthFunctions.create_new_account
    http.request(request[0])
    account = request[1]
    account = {"user_data[email]": account[:email], "user_data[password]": account[:password]}
  end

  describe 'Create new status' do
    it 'check creating new status' do
      status_name = 30.times.map {StaticData::ALPHABET.sample }.join
      request = StatusFunctions.create_new_status(account.merge({"status_data[name]" => status_name}))
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['status']['name']).to eq(status_name)
      expect(JSON.parse(response.body)['status']['color']).to eq(DefaultValues::DEFAULT_STATUS_COLOR)
    end

    it 'check creating new status with uncorrect user_data' do
      status_name = 30.times.map {StaticData::ALPHABET.sample }.join
      request = StatusFunctions.create_new_status({'status_data[name]': status_name})
      response = http.request(request[0])
      expect(response.code).to eq('201')
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'check creating new status with uncorrect status_data | no name' do
      request = Net::HTTP::Post.new('/status_new', 'Content-Type' => 'application/json')
      request.set_form_data(account.merge({"status_data[color]" => '#aaaaaa'}))
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']['name']).to eq([ErrorMessages::UNCORRECT_Status_NAME])
      expect(JSON.parse(response.body)['status']['color']).to eq('#aaaaaa')
    end

    it 'check creating new status with correct status_data | no color' do
      status_name = 30.times.map { StaticData::ALPHABET.sample }.join
      request = Net::HTTP::Post.new('/status_new', 'Content-Type' => 'application/json')
      request.set_form_data(account.merge({"status_data[name]" => status_name}))
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['status']['name']).to eq(status_name)
      expect(JSON.parse(response.body)['status']['color']).to eq(DefaultValues::DEFAULT_STATUS_COLOR)
    end
  end
end