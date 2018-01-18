require_relative '../../tests/test_management'
http, plan = nil
describe 'Run Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  before :each do
    #---plan creation
    product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
    plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
  end

  describe 'Create new run' do
    it 'check creating new run, plan and product by run_name, plan_name and product_name' do
      plan_name, product_name, = Array.new(2).map { http.random_name }
      response, run_name = RunFunctions.create_new_run(http, plan_name: plan_name,
                                                             product_name: product_name)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end

    it 'check creating new run and plan by plan_name, run_name and product_id' do
      plan_name = http.random_name
      response, run_name = RunFunctions.create_new_run(http, plan_name: plan_name,
                                                             product_id: plan['product_id'])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end

    it 'check creating new run by plan_id and run_name' do
      response, run_name = RunFunctions.create_new_run(http, plan_id: plan['id'])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end
  end

  describe 'Show runs' do
    it 'Get runs by plan_id' do
      run = JSON.parse(RunFunctions.create_new_run(http, plan_id: plan['id'])[0].body)
      result = JSON.parse(RunFunctions.get_runs(http, id: plan['id']).body)
      expect(result['errors'].empty?).to be_truthy
      expect(result['runs'].first['id']).to eq(run['run']['id'])
      expect(result['runs'].first['plan_id']).to eq(plan['id'])
    end

    it 'Get one run | show method' do
      run = JSON.parse(RunFunctions.create_new_run(http, plan_id: plan['id'])[0].body)['run']
      result = JSON.parse(RunFunctions.get_run(http, id: run['id']).body)
      result['run'].merge!('statistic' => [])
      expect(result['run']).to eq(run)
    end
  end

  describe 'Delete Run' do
    it 'Delete run by run_id' do
      run = JSON.parse(RunFunctions.create_new_run(http, plan_id: plan['id'])[0].body)['run']
      result = JSON.parse(RunFunctions.delete_run(http, id: run['id']).body)
      run_after_deleting = RunFunctions.get_run(http, id: run['id'])
      expect(result['run']).to eq(run['id'])
      expect(run_after_deleting.code).to eq('500')
    end

    it 'Delete run with result_sets by run_id' do
      run = JSON.parse(RunFunctions.create_new_run(http, plan_id: plan['id'])[0].body)['run']
      result_set_name = http.random_name
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http,run_id: run['id'],
                                                                     result_set_name: result_set_name)[0].body)
      result = JSON.parse(RunFunctions.delete_run(http, id: run['id']).body)
      run_after_deleting = RunFunctions.get_run(http, id: run['id'])
      result_set = JSON.parse(ResultSetFunctions.get_result_sets(http, id: run['id']).body)['result_set']
      expect(result['run']).to eq(run['id'])
      expect(run_after_deleting.code).to eq('500')
      expect(result_set).to be_nil
    end
  end
end
