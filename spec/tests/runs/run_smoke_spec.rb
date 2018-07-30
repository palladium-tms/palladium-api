require_relative '../../tests/test_management'
http, plan, product = nil
describe 'Run Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  before :each do
    #---plan creation
    product = ProductFunctions.create_new_product(http)[0]
    plan = PlanFunctions.create_new_plan(http, product_name: product.name)[0]
  end

  describe 'Create new run' do
    it 'check creating new run, plan and product by run_name, plan_name and product_name' do
      plan_name, product_name, = Array.new(2).map { http.random_name }
      run, run_name, code = RunFunctions.create_new_run(http, plan_name: plan_name,
                                                              product_name: product_name)
      expect(code).to eq('200')
      expect(run.plan.product.name).to eq(product_name)
      expect(run.plan.name).to eq(plan_name)
      expect(run.name).to eq(run_name)
    end

    it 'check creating new run and plan by plan_name, run_name and product_id' do
      plan_name = http.random_name
      run, run_name, code = RunFunctions.create_new_run(http, plan_name: plan_name,
                                                              product_id: plan.product_id)
      expect(code).to eq('200')
      expect(run.plan.product.id).to eq(plan.product_id)
      expect(run.plan.name).to eq(plan_name)
      expect(run.name).to eq(run_name)
    end

    it 'check creating new run by plan_id and run_name' do
      run, run_name, code = RunFunctions.create_new_run(http, plan_id: plan.id)
      expect(code).to eq('200')
      expect(run.name).to eq(run_name)
      expect(run.plan.id).to eq(plan.id)
    end

    it 'check creating new run by plan_id and run_name' do
      run, run_name, code = RunFunctions.create_new_run(http, plan_id: plan.id)
      expect(code).to eq('200')
      expect(run.name).to eq(run_name)
      expect(run.plan.id).to eq(plan.id)
    end
  end

  describe 'Show runs' do
    it 'Get runs by plan_id' do
      run = RunFunctions.create_new_run(http, plan_id: plan.id)[0]
      run_pack = RunFunctions.get_runs(http, id: plan.id)[0]
      expect(run_pack.runs.first.id).to eq(run.id)
      expect(run_pack.runs.first.plan_id).to eq(plan.id)
    end

    it 'Get one run | show method' do
      run = RunFunctions.create_new_run(http, plan_id: plan.id)[0]
      run_show = RunFunctions.get_run(http, id: run.id)[0]
      expect(run.like_a?(run_show)).to be_truthy
    end
  end

  describe 'Delete Run' do
    it 'Delete run by run_id' do
      run = RunFunctions.create_new_run(http, plan_id: plan.id)[0]
      deleted_run_id = RunFunctions.delete_run(http, id: run.id)[0]
      run_after_deleting, code = RunFunctions.get_run(http, id: run.id)
      expect(deleted_run_id).to eq(run.id)
      expect(run_after_deleting.errors).to eq('run not found')
      expect(code).to eq('200')
    end

    it 'Delete run with result_sets by run_id' do
      result_set_name = http.random_name
      run = RunFunctions.create_new_run(http, plan_id: plan.id)[0]
      ResultSetFunctions.create_new_result_set(http, run_id: run.id,
                                                     result_set_name: result_set_name)[0]
      run_deleting_id = RunFunctions.delete_run(http, id: run.id)[0]
      run_after_deleting = RunFunctions.get_run(http, id: run.id)[0]
      result_set_after_deleting = ResultSetFunctions.get_result_sets(http, id: run.id)[0]
      expect(run.id).to eq(run_deleting_id)
      expect(run_after_deleting.errors).to eq('run not found')
      expect(result_set_after_deleting.result_sets).to be_empty
    end
  end
end
