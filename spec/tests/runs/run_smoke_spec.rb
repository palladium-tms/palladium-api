require_relative '../../tests/test_management'
http, plan = nil
describe 'Run Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  before :each do
    #---plan creation
    product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
    plan = JSON.parse(PlanFunctions.create_new_plan(http, {product_name: product['name']})[0].body)['plan']
  end

  describe 'Create new run' do
    it 'check creating new run, plan and product by run_name, plan_name and product_name' do
      plan_name, product_name, = Array.new(2).map {http.random_name}
      response, run_name = RunFunctions.create_new_run(http, {plan_name: plan_name,
                                                   product_name: product_name})
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end

    it 'check creating new run and plan by plan_name, run_name and product_id' do
      plan_name = http.random_name
      response, run_name = RunFunctions.create_new_run(http, {plan_name: plan_name,
                                                              product_id: plan['product_id']})
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end

    it 'check creating new run by plan_id and run_name' do
      response, run_name = RunFunctions.create_new_run(http, {plan_id: plan['id']})
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['name']).to eq(run_name)
    end
  end

  describe 'Show runs' do
    it 'Get runs by plan_id' do
      run = JSON.parse(RunFunctions.create_new_run(http, {plan_id: plan['id']})[0].body)
      result = JSON.parse(RunFunctions.get_runs(http, id: plan['id']).body)
      expect(result['errors'].empty?).to be_truthy
      expect(result['runs'].first['id']).to eq(run['run']['id'])
      expect(result['runs'].first['plan_id']).to eq(plan['id'])
    end

    it 'Get one run | show method' do
      run = JSON.parse(RunFunctions.create_new_run(http, {plan_id: plan['id']})[0].body)['run']
      result = JSON.parse(RunFunctions.get_run(http, id: run['id']).body)
      expect(result['run']).to eq(run)
    end
    #
    # it 'Get runs by plan_id | statistic check' do
    #   run_name, product_name, result_set_name, message, plan_name = Array.new(5).map { http.random_name }
    #
    #   run = JSON.parse(RunFunctions.create_new_run(http, {plan_id: plan['id'],
    #                                                       product_name: product_name})[0].body)
    #
    #   request = RunFunctions.create_new_run(token: token, plan_id: plan_id, run_name: run_name)
    #   run_id = JSON.parse(http.request(request[0]).body)['run']['id']
    #   request = RunFunctions.get_runs(token: token, id: plan_id)
    #   request = ResultFunctions.create_new_result(token: token,
    #                                               run_id: run_id,
    #                                               result_set_name: result_set_name,
    #                                               message: message,
    #                                               status: 'Passed')
    #   http.request(request)
    #   response = http.request(RunFunctions.get_runs(token: token, id: plan_id))
    #   expect(JSON.parse(response.body)['runs'].first['statistic']).not_to be_empty
    # end
  end

  describe 'Delete Run' do
    it 'Delete run by run_id' do
      run = JSON.parse(RunFunctions.create_new_run(http, {plan_id: plan['id']})[0].body)['run']
      result = JSON.parse(RunFunctions.delete_run(http, id: run['id']).body)
      run_after_deleting = RunFunctions.get_run(http, id: run['id'])
      expect(result['run']).to eq(run['id'].to_s)
      expect(run_after_deleting.code).to eq('500')
    end
  end

  describe 'Edit Run' do
    it 'Edit run by run_id' do
      new_run_name = http.random_name
      run = JSON.parse(RunFunctions.create_new_run(http, {plan_id: plan['id']})[0].body)['run']
      response = JSON.parse(RunFunctions.update_run(http, {name: new_run_name, id: run['id']}).body)
      run = JSON.parse(RunFunctions.get_run(http, id: run['id']).body)['run']
      expect(response['run_data']['name']).to eq(run['name'])
    end
  end
end
