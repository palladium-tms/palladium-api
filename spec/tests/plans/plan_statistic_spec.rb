require_relative '../../tests/test_management'
describe 'Plan Smoke' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
    @product = @user.create_new_product
  end

  describe 'Get plan statistic' do

    before :each do
      status_name = rand_status_name
      result = @user.create_new_result(plan_name: rand_plan_name,
                                       product_id: @product.id,
                                       run_name: rand_run_name,
                                       result_set_name: rand_result_set_name,
                                       message: rand_message,
                                       status: status_name)
      @status_first = result.status
      @plan_id = result.result_set.run.plan.id
      @run_id = result.result_set.run.id
      @user.create_new_result(result_set_name: rand_result_set_name, run_id: @run_id, status: @status_first.name)
      @status_second = @user.create_new_result(result_set_name: rand_result_set_name, run_id: @run_id, status: rand_status_name).status
    end

    it 'check getting statistic of plan' do
      statistic = @user.get_plans_statistic([@plan_id])
      expect(statistic.code).to eq('200')
      expect(JSON.parse(statistic.body)['statistic']).not_to be_nil
      expect(JSON.parse(statistic.body)['statistic'][@plan_id.to_s]).not_to be_nil
      statistic = @user.reformat_statistic(JSON.parse(statistic.body)['statistic'][@plan_id.to_s])
      expect(statistic[@status_first.id]).to eq(2)
      expect(statistic[@status_second.id]).to eq(1)
    end

    it 'check getting statistic of clocked status' do
      @status_first = @user.status_edit(id: @status_first.id, block: true)
      statistic = @user.get_plans_statistic([@plan_id])
      expect(statistic.code).to eq('200')
      expect(JSON.parse(statistic.body)['statistic']).not_to be_nil
      expect(JSON.parse(statistic.body)['statistic'][@plan_id.to_s]).not_to be_nil
      statistic = @user.reformat_statistic(JSON.parse(statistic.body)['statistic'][@plan_id.to_s])
      expect(statistic[@status_first.id]).to eq(2)
      expect(statistic[@status_second.id]).to eq(1)
    end
  end

  describe 'empty statistic' do
    it 'empty statistic: only plan' do
      plan = @user.create_new_plan(product_name: @product.name)
      statistic = @user.get_plans_statistic([plan.id])
      expect(statistic.code).to eq('200')
      expect(JSON.parse(statistic.body)['statistic']).to be_empty
    end

    it 'empty statistic: plan and run' do
      plan = @user.create_new_plan(product_name: @product.name)
      @user.create_new_run(plan_id: plan.id, run_name: rand_run_name)
      statistic = @user.get_plans_statistic([plan.id])
      expect(statistic.code).to eq('200')
      expect(JSON.parse(statistic.body)['statistic']).to be_empty
    end

    it 'empty statistic: plan, run and result set' do
      plan = @user.create_new_plan(product_name: @product.name)
      run = @user.create_new_run(plan_id: plan.id, run_name: rand_run_name)
      @user.create_new_result_set(run_id: run.id, result_set_name: rand_result_set_name)
      statistic = @user.get_plans_statistic([plan.id])
      statistic = @user.reformat_statistic(JSON.parse(statistic.body)['statistic'][plan.id.to_s])
      expect(statistic).to eq(0 => 1)
    end
  end
end
