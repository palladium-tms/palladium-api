require_relative '../../tests/test_management'
http, product, plan = nil
describe 'Suites Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Create suite' do
    it 'check creating new suite after run created' do
      plan_name, product_name = Array.new(2).map { http.random_name }
      run_response, run_name = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)
      responce = SuiteFunctions.get_suites(http, id: JSON.parse(run_response.body)['product']['id'])
      run_response = JSON.parse(run_response.body)
      response = JSON.parse(responce.body)
      expect(response['suites'].find { |suite| suite['name'] == run_name }.nil?).to be_falsey
      expect(run_response['suite']['name']).to eq(run_name)
    end
  end

  describe 'Get suites' do
    it 'check getting suite' do
      product_name, plan_name = Array.new(2).map { http.random_name }
      _, run_name = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)
      _, run_name1 = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)
      run_responce, run_name2 = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)
      responce = JSON.parse(SuiteFunctions.get_suites(http, id: JSON.parse(run_responce.body)['product']['id']).body)
      expect(responce['suites'].find { |suite| suite['name'] == run_name }.nil?).to be_falsey
      expect(responce['suites'].find { |suite| suite['name'] == run_name1 }.nil?).to be_falsey
      expect(responce['suites'].find { |suite| suite['name'] == run_name2 }.nil?).to be_falsey
    end
  end

  describe 'Update suite' do
    it 'check update suite' do
      product_name, plan_name, new_suite_name = Array.new(3).map { http.random_name }
      run_responce, run_name = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)
      responce = JSON.parse(SuiteFunctions.get_suites(http, id: JSON.parse(run_responce.body)['product']['id']).body)
      created_suite = responce['suites'].find { |suite| suite['name'] == run_name }
      new_suite = SuiteFunctions.update_suite(http, id: created_suite['id'], name: new_suite_name)
      responce = JSON.parse(SuiteFunctions.get_suites(http, id: JSON.parse(run_responce.body)['product']['id']).body)
      expect(new_suite.code).to eq('200')
      expect(responce['suites'].find { |suite| suite['name'] == run_name }.nil?).to be_truthy
      expect(responce['suites'].find { |suite| suite['name'] == new_suite_name }.nil?).to be_falsey
      expect(new_suite.code).to eq('200')
    end

    it 'check update suite and runs' do
      product_name, plan_name, new_suite_name = Array.new(3).map { http.random_name }
      run_responce, run_name = RunFunctions.create_new_run_and_parse(http, plan_name: plan_name, product_name: product_name)
      suites = SuiteFunctions.get_suites_and_parse(http, id: run_responce['product']['id'])
      created_suite = suites.find { |suite| suite['name'] == run_name }
      new_suite = SuiteFunctions.update_suite(http, id: created_suite['id'], name: new_suite_name)
      update_body = JSON.parse(RunFunctions.get_runs(http, id: run_responce['plan']['id']).body)
      expect(new_suite.code).to eq('200')
      expect(update_body['runs'].find do |run|
        run['name'] == new_suite_name
      end.nil?).to be_falsey
    end

    it 'check update suite and runs only in one product' do
      product_name, product_name1, plan_name, new_suite_name = Array.new(4).map { http.random_name }
      run_responce, run_name = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)
      anternate, run_name = RunFunctions.create_new_run(http, name: run_name, plan_name: plan_name, product_name: product_name1)
      responce = JSON.parse(SuiteFunctions.get_suites(http, id: JSON.parse(run_responce.body)['product']['id']).body)
      created_suite = responce['suites'].find do |suite|
        suite['name'] == run_name
      end
      new_suite = SuiteFunctions.update_suite(http, id: created_suite['id'], name: new_suite_name)
      runs_in_other_product_after_update = JSON.parse(RunFunctions.get_runs(http, id: JSON.parse(anternate.body)['plan']['id']).body)['runs']
      expect(new_suite.code).to eq('200')
      expect(runs_in_other_product_after_update.find { |run| run['name'] == new_suite_name }.nil?).to be_truthy
      expect(runs_in_other_product_after_update.find { |run| run['name'] == run_name }.nil?).to be_falsey
    end
  end

  describe 'Delete suite' do
    it 'check deleting suite' do
      product_name, plan_name = Array.new(2).map { http.random_name }
      run_responce, run_name = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)
      responce = JSON.parse(SuiteFunctions.get_suites(http, id: JSON.parse(run_responce.body)['product']['id']).body)
      id = responce['suites'].find { |suite| suite['name'] == run_name }['id']
      responce_delete = SuiteFunctions.delete_suite(http, id: id) # deleting
      responce = JSON.parse(SuiteFunctions.get_suites(http, id: JSON.parse(run_responce.body)['product']['id']).body)
      expect(JSON.parse(responce_delete.body)['errors'].nil?).to be_truthy
      expect(responce['suites'].find { |suite| suite['name'] == run_name }.nil?).to be_truthy
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

    it 'uns after suite delete' do
      plan_name = http.random_name
      product_name = http.random_name
      run_responce, run_name = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)
      suites = JSON.parse(SuiteFunctions.get_suites(http, id: JSON.parse(run_responce.body)['product']['id']).body)['suites']
      SuiteFunctions.delete_suite(http, id: suites[0]['id']) # deleting
      suites = JSON.parse(SuiteFunctions.get_suites(http, id: JSON.parse(run_responce.body)['product']['product_id']).body)['suites']
      runs = JSON.parse(RunFunctions.get_runs(http, id: JSON.parse(run_responce.body)['plan']['id']).body)['runs']
      expect(suites).to be_empty
      expect(runs).not_to be_empty
    end
  end
end
