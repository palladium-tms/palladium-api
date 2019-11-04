require_relative '../../tests/test_management'
describe 'Plan archiving' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  before :each do
    @product = @user.create_new_product
    @plan = @user.create_new_plan(product_id: @product.id)
  end

  describe 'Plan not fully filled' do
    it 'empty product and plan archiving' do
      plan = @user.archive_plan(id: @plan.id)
      expect(plan.response.code).to eq('200')
      expect(plan.statistic).to eq('{}')
      expect(plan.is_archived).to be_truthy
      expect(plan.product_id).to eq(@product.id)
    end

    it 'archiving plan with suite' do
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
end
