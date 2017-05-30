require_relative '../../tests/test_management'
http, account, plan = nil
describe 'Run Smoke' do
  before :all do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
  end

  before :each do
    #---plan creation
    request = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_name: 30.times.map {StaticData::ALPHABET.sample}.join)[0]
    plan = JSON.parse(http.request(request).body)['plan']
  end

  describe 'Create new run' do
    it 'check creating new run, plan and product by run_name, plan_name and product_name' do
      run_name = 30.times.map {StaticData::ALPHABET.sample}.join
      plan_name = 30.times.map {StaticData::ALPHABET.sample}.join
      product_name = 30.times.map {StaticData::ALPHABET.sample}.join
      request = RunFunctions.create_new_run(token: StaticData::TOKEN, plan_name: plan_name, run_name: run_name, product_name: product_name)
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end

    it 'check creating new run and plan by plan_name, run_name and product_id' do
      product_name = 30.times.map {StaticData::ALPHABET.sample}.join
      request = ProductFunctions.create_new_product(StaticData::TOKEN, product_name)[0]
      product = JSON.parse(http.request(request).body)
      run_name = 30.times.map {StaticData::ALPHABET.sample}.join
      plan_name = 30.times.map {StaticData::ALPHABET.sample}.join
      request = RunFunctions.create_new_run(token: StaticData::TOKEN, plan_name: plan_name, run_name: run_name, product_id: product['product']['id'])
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end

    it 'check creating new run by plan_id and run_name' do
      product_name = 30.times.map {StaticData::ALPHABET.sample}.join
      request = ProductFunctions.create_new_product(StaticData::TOKEN, product_name)[0]
      product_id = JSON.parse(http.request(request).body)['product']['id']

      plan_name = 30.times.map {StaticData::ALPHABET.sample}.join
      request = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_id: product_id, plan_name: plan_name)[0]
      plan_id = JSON.parse(http.request(request).body)

      run_name = 30.times.map {StaticData::ALPHABET.sample}.join
      request = RunFunctions.create_new_run(token: StaticData::TOKEN, plan_id: plan_id['plan']['id'], run_name: run_name)
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end
  end

  describe 'Show runs' do
    it 'Get runs by plan_id' do
      product_name = 30.times.map {StaticData::ALPHABET.sample}.join
      request = ProductFunctions.create_new_product(StaticData::TOKEN, product_name)[0]
      product_id = JSON.parse(http.request(request).body)['product']['id']

      plan_name = 30.times.map {StaticData::ALPHABET.sample}.join
      request = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_id: product_id, plan_name: plan_name)[0]
      plan_id = JSON.parse(http.request(request).body)['plan']['id']

      run_name = 30.times.map {StaticData::ALPHABET.sample}.join
      request = RunFunctions.create_new_run(token: StaticData::TOKEN, plan_id: plan_id, run_name: run_name)
      run_id = JSON.parse(http.request(request[0]).body)['run']['id']

      request = RunFunctions.get_runs(token: StaticData::TOKEN, plan_id: plan_id)
      result = JSON.parse(http.request(request).body)
      expect(result['errors'].empty?).to be_truthy
      expect(result['runs'].first['id']).to eq(run_id)
      expect(result['runs'].first['plan_id']).to eq(plan_id)
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
      expect(response['errors']['run_id']).to eq([ErrorMessages::RUN_ID_WRONG])
      expect(result['runs'].empty?).to be_falsey
    end
  end
end