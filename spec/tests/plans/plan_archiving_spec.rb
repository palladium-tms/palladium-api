require_relative '../../tests/test_management'
describe 'Plan archiving' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'Plan not fully filled' do

    before :each do
      @product = @user.create_new_product
      @plan = @user.create_new_plan(product_id: @product.id)
    end

    it 'empty product and plan archiving' do
      plan = @user.archive_plan(id: @plan.id)
      expect(plan.response.code).to eq('200')
      expect(plan.statistic).to eq('{}')
      expect(plan.is_archived).to be_truthy
      expect(plan.product_id).to eq(@product.id)
    end

    it 'archiving plan with run' do
      plan_for_suite_create = @user.create_new_plan(product_id: @product.id)
      @user.create_new_run(plan_id: plan_for_suite_create.id)
      plan = @user.archive_plan(id: @plan.id)
      expect(plan.response.code).to eq('200')
      expect(plan.statistic).to eq('{}')
      expect(plan.is_archived).to be_truthy
      expect(plan.product_id).to eq(@product.id)
    end

    it 'archiving plan with suite and case: statistic check' do
      plan_for_suite_create = @user.create_new_plan(product_id: @product.id)
      run = @user.create_new_run(plan_id: plan_for_suite_create.id)
      @user.create_new_result_set(run_id: run.id)
      @plan = @user.archive_plan(id: @plan.id)
      _statistic = [{ plan_id: @plan.id, status: 0, count: 1 }].to_json
      expect(@plan.response.code).to eq('200')
      expect(@plan.is_archived).to be_truthy
      expect(@plan.statistic).to eq(_statistic)
      expect(@plan.product_id).to eq(@product.id)
    end

    it 'archiving plan with suite and case: result_set check' do
      plan_for_suite_create = @user.create_new_plan(product_id: @product.id)
      run_for_case_create = @user.create_new_run(plan_id: plan_for_suite_create.id)
      @user.create_new_result_set(run_id: run_for_case_create.id)
      @user.create_new_result_set(run_id: run_for_case_create.id)
      run = @user.create_new_run(plan_id: @plan.id, name: run_for_case_create.name)
      @user.create_new_result_set(run_id: run.id)
      result_set_count = @user.get_result_sets(id: run.id).result_sets.count
      @plan = @user.archive_plan(id: @plan.id)
      after_archive_result_set_count = @user.get_result_sets(id: run.id).result_sets.count
      expect(@plan.response.code).to eq('200')
      expect(@plan.is_archived).to be_truthy
      expect(@plan.product_id).to eq(@product.id)
      expect(result_set_count).to eq(1)
      expect(after_archive_result_set_count).to eq(3)
      expect(after_archive_result_set_count).to eq(3)
    end
  end

  describe 'Delete objects' do

    before :each do
      @product = @user.create_new_product
    end

    it 'Deleting suite' do
      @plan1 = @user.create_new_plan(product_id: @product.id)
      @plan2 = @user.create_new_plan(product_id: @product.id)
      run = @user.create_new_run(plan_id: @plan1.id)
      @plan2 = @user.archive_plan(id: @plan2.id)
      @user.delete_suite(id: @user.get_suites(id: @product.id).suites[0].id)
      @user.get_runs(id: @plan2.id).runs.count
      expect(@user.get_runs(id: @plan2.id).runs.count).to eq(1)
      expect(@user.get_runs(id: @plan2.id).runs[0].name).to eq(run.name)
    end

    it 'Deleting case' do
      @plan1 = @user.create_new_plan(product_id: @product.id)
      run = @user.create_new_run(plan_id: @plan1.id)
      name = rand_run_name
      @user.create_new_result_set(run_id: run.id, name: name)

      @plan2 = @user.create_new_plan(product_id: @product.id)
      @plan1 = @user.archive_plan(id: @plan1.id)

      this_case = @user.get_cases(product_id: @product.id, run_id: run.id).cases.find {|current_case| current_case.name ==  name}
      @user.delete_case(id: this_case.id)
      expect(@user.get_result_sets(id: run.id).result_sets.count).to eq(1)
      expect(@user.get_result_sets(id: run.id).result_sets[0].name).to eq(name)
    end
  end
end
