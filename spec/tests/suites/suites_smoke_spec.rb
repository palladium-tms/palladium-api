require_relative '../../tests/test_management'
http, plan_name, product_name = nil
describe 'Suites Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
    plan_name, product_name = Array.new(2).map { http.random_name }
  end

  describe 'Create suite' do
    it 'check creating new suite after run created' do
      run = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0]
      suite_pack = SuiteFunctions.get_suites(http, id: run.plan.product.id)
      expect(suite_pack.suites.first.name).to eq(run.name)
    end
  end

  describe 'Get suites' do
    it 'check getting suite' do
      run1 = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0]
      run2 = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0]
      run3 = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0]
      suite_pack = SuiteFunctions.get_suites(http, id: run3.plan.product.id)
      expect(suite_pack.suites.map(&:name)).to eq([run1.name, run2.name, run3.name])
    end
  end

  describe 'Update suite' do
    it 'check update suite' do
      product_name, plan_name, new_suite_name = Array.new(3).map { http.random_name }
      run = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0]
      new_suite = SuiteFunctions.update_suite(http, id: run.plan.product.suite.id, name: new_suite_name)
      suite_pack = SuiteFunctions.get_suites(http, id: run.plan.product.id)
      expect(new_suite.name).to eq(new_suite_name)
      expect(suite_pack.suites.first.name).to eq(new_suite_name)
    end

    it 'check update suite and runs' do
      product_name, plan_name, new_suite_name = Array.new(3).map { http.random_name }
      run = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0]
      new_suite = SuiteFunctions.update_suite(http, id: run.plan.product.suite.id, name: new_suite_name)
      run_pack = RunFunctions.get_runs(http, id: run.plan.id)[0]
      expect(run_pack.runs.first.name).to eq(new_suite_name)
    end

    it 'check update suite and runs only in one product' do
      product_name, product_name1, plan_name, new_suite_name = Array.new(4).map { http.random_name }
      first_run, run_name = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)
      second_run, run_name = RunFunctions.create_new_run(http, name: run_name, plan_name: plan_name, product_name: product_name1)
      new_suite = SuiteFunctions.update_suite(http, id: first_run.plan.product.suite.id, name: new_suite_name)
      runs_in_other_product = RunFunctions.get_runs(http, id: second_run.plan.id)[0]
      expect(new_suite.name).to eq(new_suite_name)
      expect(runs_in_other_product.runs.first.name).to eq(second_run.name)
    end
  end

  describe 'Delete suite' do
    it 'check deleting suite' do
      product_name, plan_name = Array.new(2).map { http.random_name }
      run, run_name = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)
      suite_pack = SuiteFunctions.get_suites(http, id: run.plan.product.id)
      SuiteFunctions.delete_suite(http, id: suite_pack.suites.first.id) # deleting
      suites_pack = SuiteFunctions.get_suites(http, id: run.plan.product.id)
      expect(suites_pack.suites).to be_empty
    end

    it 'check deleting all suites if product is deleted' do
      product, new_product_name = ProductFunctions.create_new_product(http)
      run_responce, run_name = RunFunctions.create_new_run(http, plan_name: http.random_name, product_name: new_product_name)
      ProductFunctions.delete_product(http, product.id)
      suite_pack = SuiteFunctions.get_suites(http, id: product.id)
      expect(suite_pack.suites).to be_empty
    end

    it 'Delete run after suite delete' do
      plan_name = http.random_name
      product_name = http.random_name
      run = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0]
      suite_pack = SuiteFunctions.get_suites(http, id: run.plan.product.id)
      SuiteFunctions.delete_suite(http, id: run.plan.product.suite.id) # deleting
      suite_pack = SuiteFunctions.get_suites(http, id: run.plan.product.id)
      run_pack = RunFunctions.get_runs(http, id: run.plan.id)[0]
      expect(suite_pack.suites).to be_empty
      expect(run_pack.runs).to be_empty
    end
  end
end
