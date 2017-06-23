require_relative '../../tests/test_management'
http, token = nil
describe 'Status Smoke' do
  before :each do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    token = AuthFunctions.create_user_and_get_token
  end

  describe 'Create new status' do
    it 'check creating new status' do
      status_name = 30.times.map {StaticData::ALPHABET.sample }.join
      request = StatusFunctions.create_new_status(token: token, name: status_name)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['status']['name']).to eq(status_name)
      expect(JSON.parse(response.body)['status']['color']).to eq(DefaultValues::DEFAULT_STATUS_COLOR)
    end

    it 'check creating new status with color' do
      status_name = 30.times.map {StaticData::ALPHABET.sample }.join
      status_color = '#aaccbb'
      request = StatusFunctions.create_new_status(token: token, name: status_name, color: status_color)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['status']['name']).to eq(status_name)
      expect(JSON.parse(response.body)['status']['color']).to eq(status_color)
    end

    it 'check creating new status if it has created later' do
      status_name = 30.times.map {StaticData::ALPHABET.sample }.join
      status_color = '#aaccbb'
      request = StatusFunctions.create_new_status(token: token, name: status_name, color: status_color)
      http.request(request)
      request = StatusFunctions.create_new_status(token: token, name: status_name, color: status_color)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['status']['name']).to eq(status_name)
      expect(JSON.parse(response.body)['status']['color']).to eq(status_color)
    end

    it 'check block new status' do
      status_name = 30.times.map {StaticData::ALPHABET.sample }.join
      request = StatusFunctions.create_new_status(token: token, name: status_name)
      status = JSON.parse(http.request(request).body)['status']
      request = StatusFunctions.status_edit(token: token, id: status['id'], block: true)
      response = http.request(request)
      status =  JSON.parse(response.body)
      expect(response.code).to eq('200')
      expect(status['errors'].empty?).to be_truthy
      expect(status['status']['name']).to eq(status_name)
      expect(status['status']['block']).to be_truthy
      expect(status['status']['color']).to eq(DefaultValues::DEFAULT_STATUS_COLOR)
    end

    it 'check unblock new status' do
      status_name = 30.times.map {StaticData::ALPHABET.sample }.join
      request = StatusFunctions.create_new_status(token: token, name: status_name)
      status = JSON.parse(http.request(request).body)['status']
      request = StatusFunctions.status_edit(token: token, id: status['id'], block: true)
      http.request(request)
      request = StatusFunctions.status_edit(token: token, id: status['id'], block: false)
      response = http.request(request)
      status =  JSON.parse(response.body)
      expect(response.code).to eq('200')
      expect(status['errors'].empty?).to be_truthy
      expect(status['status']['name']).to eq(status_name)
      expect(status['status']['block']).to be_falsey
      expect(status['status']['color']).to eq(DefaultValues::DEFAULT_STATUS_COLOR)
    end


    it 'check change name of status' do
      status_name = 30.times.map {StaticData::ALPHABET.sample }.join
      new_status_name = 30.times.map {StaticData::ALPHABET.sample }.join
      request = StatusFunctions.create_new_status(token: token, name: status_name)
      status = JSON.parse(http.request(request).body)['status']
      request = StatusFunctions.status_edit(token: token, name: new_status_name, id: status['id'])
      response = http.request(request)
      status =  JSON.parse(response.body)
      expect(response.code).to eq('200')
      expect(status['errors'].empty?).to be_truthy
      expect(status['status']['name']).to eq(new_status_name)
      expect(status['status']['block']).to be_falsey
      expect(status['status']['color']).to eq(DefaultValues::DEFAULT_STATUS_COLOR)
    end
  end

  describe 'Statuses get all' do
    it 'check get all statuses after create' do
      status_name = 30.times.map {StaticData::ALPHABET.sample }.join
      request = StatusFunctions.create_new_status(token: token, name: status_name)
      status = JSON.parse(http.request(request).body)['status']
      statuses = StatusFunctions.get_all_statuses(token)
      expect(statuses.key?(status['id'].to_s)).to be_truthy
    end
  end
end