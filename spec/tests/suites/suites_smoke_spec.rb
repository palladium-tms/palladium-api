require_relative '../../tests/test_management'
http, product, plan = nil
describe 'Suites Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Create suite' do
    it 'check creating new suite after run created' do
      plan_name  = Array.new(1).map { http.random_name }
      response, run_name = RunFunctions.create_new_run(http, plan_name: plan_name)
      responce = SuiteFunctions.get_suites(http, id: JSON.parse(response.body)['other_data']['product_id'])
      response = JSON.parse(responce.body)
      expect(response['suites'].find {|suite| suite['name'] == run_name}.nil?).to be_falsey
    end
  end

  describe 'Get suites' do
    it 'check getting suite' do
      plan_name = Array.new(1).map { http.random_name }
      run_responce, run_name = RunFunctions.create_new_run(http, plan_name: plan_name)
      run_responce, run_name1 = RunFunctions.create_new_run(http, plan_name: plan_name)
      run_responce, run_name2 = RunFunctions.create_new_run(http, plan_name: plan_name)
      responce = JSON.parse(SuiteFunctions.get_suites(http, id: JSON.parse(run_responce.body)['other_data']['product_id']).body)
      expect(responce['suites'].find {|suite|
        suite['name'] == run_name
      }.nil?).to be_falsey
      expect(responce['suites'].find {|suite| suite['name'] == run_name1}.nil?).to be_falsey
      expect(responce['suites'].find {|suite| suite['name'] == run_name2}.nil?).to be_falsey
    end
  end

  describe 'Delete suite' do
    it 'check deleting suite' do
      plan_name = Array.new(1).map { http.random_name }
      run_responce, run_name = RunFunctions.create_new_run(http, plan_name: plan_name)
      responce = JSON.parse(SuiteFunctions.get_suites(http, id: JSON.parse(run_responce.body)['other_data']['product_id']).body)
      id = responce['suites'].find {|suite| suite['name'] == run_name}['id']
      responce_delete = SuiteFunctions.delete_suite(http, id: id) # deleting
      responce = JSON.parse(SuiteFunctions.get_suites(http, id: JSON.parse(run_responce.body)['other_data']['product_id']).body)
      expect(JSON.parse(responce_delete.body)['errors'].nil?).to be_truthy
      expect(responce['suites'].find {|suite| suite['name'] == run_name}.nil?).to be_truthy
    end

    it 'check deleting all suites if product is deleted' do
      res_new_product, new_product_name = ProductFunctions.create_new_product(http)
      product_id = JSON.parse(res_new_product.body)['product']['id']
      plan_name = Array.new(1).map { http.random_name }
      run_responce, run_name = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: new_product_name)
      ProductFunctions.delete_product(http, product_id)
      responce = JSON.parse(SuiteFunctions.get_suites(http, id: product_id).body)
      expect(responce['suites']).to be_empty
    end
  end
end
