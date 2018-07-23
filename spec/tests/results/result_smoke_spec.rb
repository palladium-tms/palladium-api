require_relative '../../tests/test_management'
http, product_name, plan_name, run_name, result_set_name, message = nil
describe 'Result Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Create new result' do
    before :each do
      product_name, plan_name, run_name, result_set_name, message = Array.new(5).map { http.random_name }
    end

    it '1. Check creating new result with all other elements' do
      result = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                       run_name: run_name,
                                                       product_name: product_name,
                                                       result_set_name: result_set_name,
                                                       message: message,
                                                       status: 'Passed')[0]
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(result_set_name)
      expect(result.result_set.run.plan.product.name).to eq(product_name)
      expect(result.result_set.run.plan.name).to eq(plan_name)
      expect(result.result_set.run.name).to eq(run_name)
      expect(result.message).to eq(message)
      expect(result.status.name).to eq('Passed')
    end

    it '2. Check creating new result | only product has created before' do
      product = ProductFunctions.create_new_product(http)[0]
      result = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                       run_name: run_name,
                                                       product_id: product.id,
                                                       result_set_name: result_set_name,
                                                       message: message,
                                                       status: 'Passed')[0]
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(result_set_name)
      expect(result.result_set.run.plan.product.name).to eq(product.name)
      expect(result.result_set.run.plan.name).to eq(plan_name)
      expect(result.result_set.run.name).to eq(run_name)
      expect(result.message).to eq(message)
      expect(result.status.name).to eq('Passed')
    end

    it '3. Check creating new result | only product and plan has created before' do
      product = ProductFunctions.create_new_product(http)[0]
      plan = PlanFunctions.create_new_plan(http, product_id: product.id)[0]
      result = ResultFunctions.create_new_result(http,
                                                 plan_id: plan.id,
                                                 run_name: run_name,
                                                 result_set_name: result_set_name,
                                                 message: message,
                                                 status: 'Passed')[0]
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(result_set_name)
      expect(result.result_set.run.plan.name).to eq(plan.name)
      expect(result.result_set.run.name).to eq(run_name)
      expect(result.message).to eq(message)
      expect(result.status.name).to eq('Passed')
    end

    it '4. Check creating new result | only product, plan and run has created before' do
      run = RunFunctions.create_new_run(http, plan_name: http.random_name,
                                              product_name: http.random_name)[0]
      result = ResultFunctions.create_new_result(http, run_id: run.id,
                                                       result_set_name: result_set_name,
                                                       message: message,
                                                       status: 'Passed')[0]
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(result_set_name)
      expect(result.result_set.run.name).to eq(run.name)
      expect(result.message).to eq(message)
      expect(result.status.name).to eq('Passed')
    end

    it '5. Check creating new result | only product, plan, run and result set has created before' do
      run = RunFunctions.create_new_run(http, plan_name: http.random_name,
                                              product_name: http.random_name)[0]
      result_set = ResultSetFunctions.create_new_result_set(http,
                                                            run_id: run.id,
                                                            name: result_set_name)[0]
      result = ResultFunctions.create_new_result(http,
                                                 result_set_id: result_set.id,
                                                 message: message,
                                                 status: 'Passed')[0]
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(result_set_name)
      expect(result.message).to eq(message)
      expect(result.status.name).to eq('Passed')
    end

    # You can send array of result_sets for create this result for every this result_sets
    it '6. Create result from multiple creator' do
      run = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0]
      result_set_array = (1..3).to_a.map do |iterator|
        ResultSetFunctions.create_new_result_set(http,
                                                 run_id: run.id,
                                                 name: result_set_name + iterator.to_s)[0].id
      end

      result = ResultFunctions.create_new_result(http,
                                                 result_set_id: result_set_array,
                                                 message: message,
                                                 status: 'Passed')[0]
      expect(result.response.code).to eq('200')
      expect = [result_set_name + '1', result_set_name + '2', result_set_name + '3']
      expect(result.result_set.result_sets.map(&:name)).to eq(expect)
      expect(result.message).to eq(message)
      expect(result.status.name).to eq('Passed')
    end

    it '8. Create result by case id and plan id' do
      product = ProductFunctions.create_new_product(http)[0]
      result = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                       run_name: run_name,
                                                       product_id: product.id,
                                                       result_set_name: result_set_name,
                                                       message: message,
                                                       status: 'Passed')[0]
      plan = PlanFunctions.create_new_plan(http, name: plan_name + '_new', product_id: product.id)[0]
      cases = CaseFunctions.get_cases(http, id: result.result_set.run.plan.product.suite.id)

      result_responce = ResultFunctions.create_new_result(http, plan_id: plan.id,
                                                                case_id: cases.cases.first.id,
                                                                message: message,
                                                                status: 'Passed')[0]
      expect(result_responce.response.code).to eq('200')
      expect(result_responce.is_null).to be_falsey
      expect(result_responce.result_set.name).to eq(cases.cases.first.name)
      expect(result_responce.result_set.run.plan.id).to eq(plan.id)
    end

    it '9. Check creating new result with + in name' do
      run = RunFunctions.create_new_run(http, plan_name: http.random_name,
                                              product_name: http.random_name)[0]
      result_set = ResultSetFunctions.create_new_result_set(http,
                                                            run_id: run.id,
                                                            name: '123123 + 123123')[0]
      result = ResultFunctions.create_new_result(http,
                                                 result_set_id: result_set.id,
                                                 message: message,
                                                 status: 'Passed')[0]
      expect(result.response.code).to eq('200')
      expect(result.is_null).to be_falsey
      expect(result.result_set.name).to eq('123123 + 123123')
    end

    it '10. Create result by array with name and run id' do
      product = ProductFunctions.create_new_product(http)[0]
      result_sets = (1..3).to_a.map do |iterator|
        ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                run_name: run_name,
                                                product_id: product.id,
                                                result_set_name: result_set_name + iterator.to_s,
                                                message: message,
                                                status: 'Passed')[0]
      end
      plan = PlanFunctions.create_new_plan(http, name: plan_name + '_new', product_id: product.id)[0]
      cases = CaseFunctions.get_cases(http, id: result_sets[0].result_set.run.plan.product.suite.id)
      result = ResultFunctions.create_new_result(http, plan_id: plan.id,
                                                       case_id: cases.cases.map(&:id),
                                                       message: message,
                                                       status: 'Passed')[0]
      expect(result.response.code).to eq('200')
      expect(result.result_set.result_sets.count).to eq(3)
      expect(result.result_set.result_sets.map(&:name)).to eq(cases.cases.map(&:name))
      expect(result.is_null).to be_falsey
    end
  end

  describe 'Get results' do
    before :each do
      product_name, plan_name, run_name, result_set_name, message = Array.new(5).map { http.random_name }
    end

    it 'get results by result_set_id' do
      run = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0]
      result_set = ResultSetFunctions.create_new_result_set(http, run_id: run.id,
                                                                  result_set_name: result_set_name)[0]
      result = ResultFunctions.create_new_result(http,
                                                 result_set_id: result_set.id,
                                                 message: message,
                                                 status: 'Passed')[0]
      result_pack = ResultFunctions.get_results(http, id: result_set.id)
      expect(result_pack.results.count).to eq(1)
      expect(result_pack.results.first.id).to eq(result.id)
    end
  end

  describe 'Get result' do
    it 'get result for one result' do
      result_set_name, message, product_name, plan_name = Array.new(5).map { http.random_name }
      run = RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0]
      result_set = ResultSetFunctions.create_new_result_set(http, run_id: run.id,
                                                                  result_set_name: result_set_name)[0]
      ResultFunctions.create_new_result(http,
                                        result_set_id: result_set.id,
                                        message: message,
                                        status: 'Passed')
      results_pack = ResultFunctions.get_results(http, id: result_set.id)
      result = ResultFunctions.get_result(http, results_pack.results.first.id)
      expect(result.id).to eq(results_pack.results.first.id)
      expect(result.message).to eq(message)
    end
  end
end
