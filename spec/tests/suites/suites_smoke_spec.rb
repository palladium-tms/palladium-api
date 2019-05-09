require_relative '../../tests/test_management'
describe 'Suites Smoke' do
  before :each do
    @user = AccountFunctions.create_and_parse
    @user.login
    @params = {plan_name: rand_plan_name, product_name: rand_product_name,
               run_name: rand_run_name, name: rand_run_name}
  end

  describe 'Create suite' do
    it 'check creating new suite after run created' do
      run = @user.create_new_run(plan_name: rand_plan_name, product_name: rand_product_name)
      suite_pack = @user.get_suites(id: run.plan.product.id)
      expect(suite_pack.suites.first.name).to eq(run.name)
    end
  end

  describe 'Get suites' do
    it 'check getting suite' do
      product_name = rand_product_name
      run1 = @user.create_new_run(plan_name: rand_plan_name, product_name: product_name)
      run2 = @user.create_new_run(plan_name: rand_plan_name, product_name: product_name)
      run3 = @user.create_new_run(plan_name: rand_plan_name, product_name: product_name)
      suite_pack = @user.get_suites(id: run3.plan.product.id)
      expect(suite_pack.suites.map(&:name) & [run1.name, run2.name, run3.name]).to eq([run1.name, run2.name, run3.name])
    end
  end

  describe 'Update suite' do
    it 'check update suite' do
      run = @user.create_new_run(plan_name: @params[:plan_name], product_name: @params[:product_name])
      new_suite_name = rand_run_name
      new_suite = @user.update_suite(id: run.plan.product.suite.id, name: new_suite_name)
      suite_pack = @user.get_suites(id: run.plan.product.id)
      expect(new_suite.name).to eq(new_suite_name)
      expect(suite_pack.suites.first.name).to eq(new_suite_name)
    end

    it 'check update suite and runs' do
      run = @user.create_new_run(plan_name: @params[:plan_name], product_name: @params[:product_name])
      new_suite_name = rand_run_name
      @user.update_suite(id: run.plan.product.suite.id, name: new_suite_name)
      run_pack = @user.get_runs(id: run.plan.id)
      expect(run_pack.runs.first.name).to eq(new_suite_name)
    end

    it 'check update suite and runs only in one product' do
      run_name = rand_run_name
      new_suite_name = rand_run_name
      first_run = @user.create_new_run(name: run_name, plan_name: @params[:plan_name], product_name: rand_product_name)
      second_run = @user.create_new_run(name: run_name, plan_name: @params[:plan_name], product_name: rand_product_name)
      new_suite = @user.update_suite(id: first_run.plan.product.suite.id, name: new_suite_name)
      runs_in_other_product = @user.get_runs(id: second_run.plan.id)
      expect(new_suite.name).to eq(new_suite_name)
      expect(runs_in_other_product.runs.first.name).to eq(second_run.name)
    end
  end

  describe 'Delete suite' do
    it 'check deleting suite' do
      run = @user.create_new_run(plan_name: @params[:plan_name], product_name: @params[:product_name])
      suite_pack = @user.get_suites(id: run.plan.product.id)
      @user.delete_suite(id: suite_pack.suites.first.id) # deleting
      suites_pack = @user.get_suites(id: run.plan.product.id)
      expect(suites_pack.suites).to be_empty
    end

    it 'check deleting all suites if product is deleted' do
      product = @user.create_new_product
      product = @user.create_new_run(plan_name: rand_run_name, product_name: product.name)
      @user.delete_product(product.id)
      suite_pack = @user.get_suites(id: product.id)
      expect(suite_pack.suites).to be_empty
    end

    it 'Delete run after suite delete' do
      run = @user.create_new_run(plan_name: rand_plan_name, product_name: rand_product_name)
      @user.delete_suite(id: run.plan.product.suite.id)
      suite_pack = @user.get_suites(id: run.plan.product.id)
      run_pack = @user.get_runs(id: run.plan.id)
      expect(suite_pack.suites).to be_empty
      expect(run_pack.runs).to be_empty
    end
  end
end
