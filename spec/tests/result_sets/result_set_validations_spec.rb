require_relative '../../tests/test_management'
http =  nil
describe 'Result Set Validations' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Create new result_sets' do
    it 'creating result_set with empty product name' do
      plan_name, run_name, result_set_name = Array.new(3).map { http.random_name }
      result_set = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                  run_name: run_name,
                                                                  product_name: '',
                                                                  name: result_set_name)[0]
      responce = JSON.parse(result_set.response.body)
      expect(responce['run_errors']).to eq('product or plan creating error')
      expect(responce['plan_errors']).to eq('product creating error')
      expect(responce['product_errors']).to eq(['name cannot be empty'])
      expect(result_set.errors).to eq('product, plan or run creating error')
    end

    it 'creating result_set with empty plan name' do
      product = ProductFunctions.create_new_product(http)[0]
      run_name, result_set_name = Array.new(2).map { http.random_name }
      result_set = ResultSetFunctions.create_new_result_set(http, plan_name: '',
                                                                  run_name: run_name,
                                                                  product_id: product.id,
                                                                  name: result_set_name)[0]
      responce = JSON.parse(result_set.response.body)
      expect(responce['run_errors']).to eq('product or plan creating error')
      expect(responce['plan_errors']).to eq(['name cannot be empty'])
      expect(result_set.errors).to eq('product, plan or run creating error')
    end

    it 'creating result_set with empty run name' do
      plan_name, result_set_name = Array.new(2).map { http.random_name }
      plan = PlanFunctions.create_new_plan(http, product_name: plan_name)[0]
      result_set = ResultSetFunctions.create_new_result_set(http, run_name: '',
                                                                  name: result_set_name,
                                                                  plan_id: plan.id)[0]
      responce = JSON.parse(result_set.response.body)
      expect(responce['run_errors']).to eq(['name cannot be empty'])
      expect(result_set.errors).to eq('product, plan or run creating error')
    end

    it 'creating result_set with empty result_set_name name' do
      product_name, plan_name = Array.new(2).map { http.random_name }
      run = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0]
      result_set = ResultSetFunctions.create_new_result_set(http, run_id: run.id,
                                                                  name: '')[0]
      expect(result_set.errors).to eq([['name cannot be empty']])
    end
  end
end
