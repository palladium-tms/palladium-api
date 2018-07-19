require_relative '../../tests/test_management'
http, product_name, plan_name, run_name, result_set_name, message = nil
describe 'Result Set Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
    product_name = 'Product_' + http.random_name
    plan_name = 'Plan_' + http.random_name
    run_name = 'Run_' + http.random_name
    result_set_name = 'Result_set_' + http.random_name
  end

  describe 'Create new result_sets' do
    it '1. Create product, plan, run and result set in one time' do
      result_set = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                  run_name: run_name,
                                                                  product_name: product_name,
                                                                  name: result_set_name)[0]
      expect(result_set.run.plan.product.name).to eq(product_name)
      expect(result_set.run.plan.name).to eq(plan_name)
      expect(result_set.run.name).to eq(run_name)
      expect(result_set.name).to eq(result_set_name)
    end

    it '2. Create plan, run and result set in one time' do
      product = ProductFunctions.create_new_product(http)[0]
      result_set = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                  run_name: run_name,
                                                                  product_id: product.id,
                                                                  name: result_set_name)[0]
      expect(result_set.run.plan.product.name).to eq(product.name)
      expect(result_set.run.plan.name).to eq(plan_name)
      expect(result_set.run.name).to eq(run_name)
      expect(result_set.name).to eq(result_set_name)
    end

    it '3. Create run and result set in one time' do
      product = ProductFunctions.create_new_product(http)[0]
      plan = PlanFunctions.create_new_plan(http, product_name: product.name)[0]
      result_set = ResultSetFunctions.create_new_result_set(http, plan_id: plan.id,
                                                                  run_name: run_name,
                                                                  name: result_set_name)[0]
      expect(result_set.run.plan.like_a?(plan)).to be_truthy
      expect(result_set.run.name).to eq(run_name)
      expect(result_set.name).to eq(result_set_name)
    end

    it '4. Create result set in one time' do
      product = ProductFunctions.create_new_product(http)[0]
      plan = PlanFunctions.create_new_plan(http, product_name: product.name)[0]
      run = RunFunctions.create_new_run(http, plan_id: plan.id)[0]
      result_set_name = http.random_name
      result_set = ResultSetFunctions.create_new_result_set(http, run_id: run.id,
                                                                  name: result_set_name)[0]
      expect(result_set.run.id).to eq(run.id)
      expect(result_set.name).to eq(result_set_name)
    end
  end

  describe 'Show result_set' do
    it 'get result_sets by run_id' do
      product = ProductFunctions.create_new_product(http)[0]
      plan = PlanFunctions.create_new_plan(http, product_name: product.name)[0]
      run = RunFunctions.create_new_run(http, plan_id: plan.id)[0]
      result_set = ResultSetFunctions.create_new_result_set(http, plan_id: plan.id,
                                                                  run_id: run.id)[0]
      result_set_pack = ResultSetFunctions.get_result_sets(http, id: run.id)[0]
      expect(result_set_pack.result_sets.first.like_a?(result_set)).to be_truthy
      expect(result_set_pack.result_sets.first.id).to eq(result_set.id)
      expect(result_set_pack.result_sets.first.run_id).to eq(run.id)
    end

    it 'get result_set | show method' do
      product = ProductFunctions.create_new_product(http)[0]
      plan = PlanFunctions.create_new_plan(http, product_name: product.name)[0]
      run = RunFunctions.create_new_run(http, plan_id: plan.id)[0]
      result_set = ResultSetFunctions.create_new_result_set(http, plan_id: plan.id,
                                                                  run_id: run.id)[0]
      result_set_show = ResultSetFunctions.get_result_set(http, id: result_set.id)
      expect(result_set.like_a?(result_set_show)).to be_truthy
    end
  end

  describe 'Delete result_set' do
    it 'Delete result set' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map { http.random_name }
      responce = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                run_name: run_name,
                                                                product_name: product_name,
                                                                name: result_set_name)[0]
      delete_responce = ResultSetFunctions.delete_result_set(http, id: responce.id)[0]
      result_ser_after_deleting = ResultSetFunctions.get_result_set(http, id: responce.id)
      expect(delete_responce['result_set']['id']).to eq(responce.id)
      expect(result_ser_after_deleting.response.code).to eq('200')
    end
  end
end
