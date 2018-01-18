require_relative '../../tests/test_management'
http, run_id, result_set, result_set_id, token = nil
describe 'Result Set Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Create new result_sets' do
    it '1. Create product, plan, run and result set in one time' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map { http.random_name }
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                           run_name: run_name,
                                                                           product_name: product_name,
                                                                           name: result_set_name)[0].body)
      expect(responce['errors']).to eq([{}])
      expect(responce['result_set'][0]['name']).to eq(result_set_name)
    end

    it '2. Create plan, run and result set in one time' do
      product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
      plan_name, run_name, result_set_name = Array.new(4).map { http.random_name }
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                           run_name: run_name,
                                                                           product_id: product['id'],
                                                                           name: result_set_name)[0].body)
      expect(responce['errors']).to eq([{}])
      expect(responce['result_set'][0]['name']).to eq(result_set_name)
    end

    it '3. Create run and result set in one time' do
      product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
      plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
      run_name, result_set_name = Array.new(4).map { http.random_name }
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_id: plan['id'],
                                                                           run_name: run_name,
                                                                           name: result_set_name)[0].body)
      expect(responce['errors']).to eq([{}])
      expect(responce['result_set'][0]['name']).to eq(result_set_name)
    end

    it '4. Create result set in one time' do
      product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
      plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
      run = JSON.parse(RunFunctions.create_new_run(http, plan_id: plan['id'])[0].body)['run']
      result_set_name = http.random_name
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http,run_id: run['id'],
                                                                           name: result_set_name)[0].body)
      expect(responce['errors']).to eq([{}])
      expect(responce['result_set'][0]['name']).to eq(result_set_name)
    end
  end

  describe 'Show result_set' do
    it 'get result_sets by run_id' do
      product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
      plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
      run = JSON.parse(RunFunctions.create_new_run(http, plan_id: plan['id'])[0].body)['run']
      result_set = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_id: plan['id'],
                                                                             run_id: run['id'])[0].body)['result_set'][0]
      responce = JSON.parse(ResultSetFunctions.get_result_sets(http, id: run['id']).body)
      expect(responce['errors']).to eq([])
      expect(responce['result_sets'].first['id']).to eq(result_set['id'])
      expect(responce['result_sets'].first['run_id']).to eq(result_set['run_id'])
    end

    it 'get result_set | show method' do
      product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
      plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
      run = JSON.parse(RunFunctions.create_new_run(http, plan_id: plan['id'])[0].body)['run']
      result_set = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_id: plan['id'],
                                                                             run_id: run['id'])[0].body)['result_set'][0]
      responce = JSON.parse(ResultSetFunctions.get_result_set(http, id: result_set['id']).body)['result_set']
      expect(responce).to eq(result_set)
    end
  end

  describe 'Delete result_set' do
    it 'Delete result set' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map { http.random_name }
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                           run_name: run_name,
                                                                           product_name: product_name,
                                                                           name: result_set_name)[0].body)['result_set'][0]
      delete_responce = JSON.parse(ResultSetFunctions.delete_result_set(http, id: responce['id']).body)
      result_ser_after_deleting = ResultSetFunctions.get_result_set(http, id: responce['id'])
      expect(delete_responce['result_set']['id']).to eq(responce['id'])
      expect(result_ser_after_deleting.code).to eq('500')
    end
  end
end
