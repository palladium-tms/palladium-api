require_relative '../../tests/test_management'
http = nil
describe 'Status Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Create new status' do
    it 'check creating new status' do
      status_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      response = JSON.parse(StatusFunctions.create_new_status(http, {name: status_name}).body)
      expect(response['errors'].empty?).to be_truthy
      expect(response['status']['name']).to eq(status_name)
      expect(response['status']['color']).to eq(DefaultValues::DEFAULT_STATUS_COLOR)
    end

    it 'check creating new status with color' do
      status_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      response = StatusFunctions.create_new_status(http, {name: status_name, color: '#aaccbb'})
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['status']['name']).to eq(status_name)
      expect(JSON.parse(response.body)['status']['color']).to eq('#aaccbb')
    end

    it 'check creating new status if it has created later' do
      status_name = http.random_name
      status_color = '#aaccbb'
      StatusFunctions.create_new_status(http, {name: status_name, color: status_color})
      response = StatusFunctions.create_new_status(http, name: status_name, color: status_color)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['status']['name']).to eq(status_name)
      expect(JSON.parse(response.body)['status']['color']).to eq(status_color)
    end

    it 'check block new status' do
      status_name = http.random_name
      status = JSON.parse(StatusFunctions.create_new_status(http, name: status_name).body)['status']
      response = JSON.parse(StatusFunctions.status_edit(http, id: status['id'], block: true).body)
      expect(response['errors'].empty?).to be_truthy
      expect(response['status']['name']).to eq(status_name)
      expect(response['status']['block']).to be_truthy
      expect(response['status']['color']).to eq(DefaultValues::DEFAULT_STATUS_COLOR)
    end

    it 'check unblock new status' do
      status_name = http.random_name
      status = JSON.parse(StatusFunctions.create_new_status(http, name: status_name).body)['status']
      JSON.parse(StatusFunctions.status_edit(http, id: status['id'], block: true).body)
      response = StatusFunctions.status_edit(http, id: status['id'], block: false)
      status = JSON.parse(response.body)
      expect(response.code).to eq('200')
      expect(status['errors'].empty?).to be_truthy
      expect(status['status']['name']).to eq(status_name)
      expect(status['status']['block']).to be_falsey
      expect(status['status']['color']).to eq(DefaultValues::DEFAULT_STATUS_COLOR)
    end

    it 'check change name of status' do
      status_name, new_status_name = Array.new(2).map { http.random_name }
      status = JSON.parse(StatusFunctions.create_new_status(http, name: status_name).body)['status']
      response = StatusFunctions.status_edit(http, {id: status['id'], name: new_status_name})
      status_new = JSON.parse(response.body)
      expect(response.code).to eq('200')
      expect(status_new['errors'].empty?).to be_truthy
      expect(status_new['status']['name']).to eq(new_status_name)
      expect(status_new['status']['block']).to be_falsey
      expect(status_new['status']['color']).to eq(DefaultValues::DEFAULT_STATUS_COLOR)
    end
  end

  describe 'Statuses get all' do
    it 'check get all statuses after create' do
      status_name = http.random_name
      status = JSON.parse(StatusFunctions.create_new_status(http, name: status_name).body)['status']
      statuses = JSON.parse(StatusFunctions.get_all_statuses(http).body)['statuses']
      expect(statuses.key?(status['id'].to_s)).to be_truthy
    end

    it 'check get not blocked statuses after create' do
      status_name_block = http.random_name
      status_name = http.random_name
      status_block = JSON.parse(StatusFunctions.create_new_status(http, name: status_name_block).body)['status']
      status_not_block = JSON.parse(StatusFunctions.create_new_status(http, name: status_name).body)['status']
      JSON.parse(StatusFunctions.status_edit(http, id: status_block['id'], block: true).body)
      statuses = JSON.parse(StatusFunctions.get_not_blocked_statuses(http).body)['statuses']
      expect(statuses.key?(status_not_block['id'].to_s)).to be_truthy
      expect(statuses.key?(status_block['id'].to_s)).to be_falsey
    end
  end
end
