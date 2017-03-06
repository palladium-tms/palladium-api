require_relative '../../tests/test_management'
http, account, plan = nil
describe 'Run Smoke' do
  before :each do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    request = AuthFunctions.create_new_account
    http.request(request[0])
    account = request[1]

    product = ProductFunctions.create_new_product(account)
    product_id = JSON.parse(http.request(product[0]).body)['product']['id']

    account = {"user_data[email]": account[:email], "user_data[password]": account[:password]}

    plan_request = PlanFunctions.create_new_plan(account.merge({"plan_data[product_id]" => product_id}))
    plan = JSON.parse(http.request(plan_request[0]).body)['plan']
  end
  describe 'Create new run' do
    it 'check creating new run' do
      request = RunFunctions.create_new_run(account.merge({"run_data[plan_id]" => plan['id']}))
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['run']['name']).to eq(request[1])
      expect(JSON.parse(response.body)['run']['plan_id']).to eq(plan['id'])
    end

    it 'check creating new run without user_data' do
      request = RunFunctions.create_new_run({"run_data[plan_id]" => plan['id']})
      response = http.request(request[0])
      expect(response.code).to eq('201')
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'check creating new run with uncorrect run_data | plan_id' do
      uncorrect_plan_id = 30.times.map { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(account.merge({"run_data[plan_id]" => uncorrect_plan_id}))
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']['plan_id']).to eq([ErrorMessages::PLAN_ID_WRONG])
    end
  end

  describe 'Show runs' do
    it 'Get runs by plan_id' do
      request = RunFunctions.create_new_run(account.merge({"run_data[plan_id]" => plan['id']}))
      response = http.request(request[0])
      run_id = JSON.parse(response.body)['run']['id']
      result = RunFunctions.get_plans(account.merge({"run_data[plan_id]" => plan['id']}))
      expect(result['errors'].empty?).to be_truthy
      expect(result['runs'].first['id']).to eq(run_id)
      expect(result['runs'].first['plan_id']).to eq(plan['id'])
    end

    it 'Get runs by plan_id without user_data' do
      request = RunFunctions.create_new_run(account.merge({"run_data[plan_id]" => plan['id']}))
      http.request(request[0])
      result = RunFunctions.get_plans({"run_data[plan_id]" => plan['id']})
      expect(result['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'Get runs by plan_id with uncorrect run_data | plan_id' do
      plan_id = 30.times.map { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(account.merge({"run_data[plan_id]" => plan['id']}))
      http.request(request[0])
      result = RunFunctions.get_plans(account.merge({"run_data[plan_id]" => plan_id}))
      expect(result['errors']['plan_id']).to eq([ErrorMessages::PLAN_ID_WRONG])
    end
  end

  describe 'Delete Run' do
    it 'check deleting run after run create' do
      request = RunFunctions.create_new_run(account.merge({"run_data[plan_id]" => plan['id']}))
      response = http.request(request[0])
      run_id = JSON.parse(response.body)['run']['id']
      request = RunFunctions.delete_run(account.merge({"run_data[id]" => run_id}))
      response = JSON.parse(http.request(request).body)
      result = RunFunctions.get_plans(account.merge({"run_data[plan_id]" => plan['id']}))
      expect(result['runs'].empty?).to be_truthy
      expect(response['errors'].empty?).to be_truthy
      expect(response['plan']).to eq(run_id.to_s)
    end

    it 'check deleting run with uncorrect user_data' do
      request = RunFunctions.create_new_run(account.merge({"run_data[plan_id]" => plan['id']}))
      response = http.request(request[0])
      run_id = JSON.parse(response.body)['run']['id']
      request = RunFunctions.delete_run({"run_data[id]" => run_id})
      response = JSON.parse(http.request(request).body)
      result = RunFunctions.get_plans(account.merge({"run_data[plan_id]" => plan['id']}))
      expect(result['runs'].empty?).to be_falsey
      expect(response['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'check deleting run with uncorrect run_data | id' do
      uncorrect_id = 30.times.map { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(account.merge({"run_data[plan_id]" => plan['id']}))
      http.request(request[0])
      request = RunFunctions.delete_run(account.merge({"run_data[id]" => uncorrect_id}))
      response = JSON.parse(http.request(request).body)
      result = RunFunctions.get_plans(account.merge({"run_data[plan_id]" => plan['id']}))
      expect(response['errors']['plan_id']).to eq([ErrorMessages::RUN_ID_WRONG])
      expect(result['runs'].empty?).to be_falsey
    end
  end
end