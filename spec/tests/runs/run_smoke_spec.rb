require_relative '../../tests/test_management'
http, token = nil
describe 'Run Smoke' do
  before :all do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    token = AuthFunctions.create_user_and_get_token
  end

  before :each do
    #---plan creation
    request = PlanFunctions.create_new_plan(token: token, product_name: Array.new(30) { StaticData::ALPHABET.sample }.join)[0]
    plan = JSON.parse(http.request(request).body)['plan']
  end

  describe 'Create new run' do
    it 'check creating new run, plan and product by run_name, plan_name and product_name' do
      run_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      plan_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      product_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(token: token, plan_name: plan_name, run_name: run_name, product_name: product_name)
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end

    it 'check creating new run and plan by plan_name, run_name and product_id' do
      product_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = ProductFunctions.create_new_product(token, product_name)[0]
      product = JSON.parse(http.request(request).body)
      run_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      plan_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(token: token, plan_name: plan_name, run_name: run_name, product_id: product['product']['id'])
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end

    it 'check creating new run by plan_id and run_name' do
      product_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = ProductFunctions.create_new_product(token, product_name)[0]
      product_id = JSON.parse(http.request(request).body)['product']['id']

      plan_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = PlanFunctions.create_new_plan(token: token, product_id: product_id, plan_name: plan_name)[0]
      plan_id = JSON.parse(http.request(request).body)

      run_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(token: token, plan_id: plan_id['plan']['id'], run_name: run_name)
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end
  end

  describe 'Show runs' do
    it 'Get runs by plan_id' do
      product_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = ProductFunctions.create_new_product(token, product_name)[0]
      product_id = JSON.parse(http.request(request).body)['product']['id']

      plan_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = PlanFunctions.create_new_plan(token: token, product_id: product_id, plan_name: plan_name)[0]
      plan_id = JSON.parse(http.request(request).body)['plan']['id']

      run_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(token: token, plan_id: plan_id, run_name: run_name)
      run_id = JSON.parse(http.request(request[0]).body)['run']['id']

      request = RunFunctions.get_runs(token: token, id: plan_id)
      result = JSON.parse(http.request(request).body)
      expect(result['errors'].empty?).to be_truthy
      expect(result['runs'].first['id']).to eq(run_id)
      expect(result['runs'].first['plan_id']).to eq(plan_id)
    end

    it 'Get runs by plan_id | statistic check' do
      run_name, product_name, result_set_name, message, plan_name = Array.new(5).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      request = ProductFunctions.create_new_product(token, product_name)[0]
      product_id = JSON.parse(http.request(request).body)['product']['id']
      request = PlanFunctions.create_new_plan(token: token, product_id: product_id, plan_name: plan_name)[0]
      plan_id = JSON.parse(http.request(request).body)['plan']['id']
      request = RunFunctions.create_new_run(token: token, plan_id: plan_id, run_name: run_name)
      run_id = JSON.parse(http.request(request[0]).body)['run']['id']
      request = RunFunctions.get_runs(token: token, id: plan_id)
      request = ResultFunctions.create_new_result(token: token,
                                                  run_id: run_id,
                                                  result_set_name: result_set_name,
                                                  message: message,
                                                  status: 'Passed')
      http.request(request)
      response = http.request(RunFunctions.get_runs(token: token, id: plan_id))
      expect(JSON.parse(response.body)['runs'].first['statistic']).not_to be_empty
    end
  end

  describe 'Delete Run' do
    it 'Delete run by run_id' do
      run_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      plan_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      product_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(token: token, plan_name: plan_name, run_name: run_name, product_name: product_name)
      response = JSON.parse(http.request(request[0]).body)
      run = response['run']
      # -----------
      request = RunFunctions.delete_run(token: token, id: run['id'])
      response = JSON.parse(http.request(request).body)
      expect(response['run']).to eq(run['id'].to_s)
      expect(response['errors'].empty?).to be_truthy
      request = RunFunctions.get_runs(token: token, plan_id: run['plan_id'])
      result = JSON.parse(http.request(request).body)
      expect(result['runs']).to be_empty
    end
  end

  describe 'Edit Run' do
    it 'Edit run by run_id' do
      run_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      new_run_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      plan_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      product_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(token: token, plan_name: plan_name, run_name: run_name, product_name: product_name)
      response = JSON.parse(http.request(request[0]).body)
      run = response['run']
      # -----------
      request = RunFunctions.update_run(token: token, name: new_run_name, id: run['id'])
      response = JSON.parse(http.request(request).body)
      expect(response['run_data']['name']).to eq(new_run_name)
      expect(response['errors']).to be_empty
      request = RunFunctions.get_runs(token: token, id: run['plan_id'])
      response = JSON.parse(http.request(request).body)
      expect(response['runs'].first['name']).to eq(new_run_name)
    end
  end
end
