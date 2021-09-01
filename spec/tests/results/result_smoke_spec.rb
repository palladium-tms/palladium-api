require_relative '../../tests/test_management'
describe 'Result Smoke' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'Create new result' do
    before do
      @params = { plan_name: rand_plan_name,
                  product_name: rand_product_name,
                  run_name: rand_run_name,
                  result_set_name: rand_result_set_name,
                  message: rand_message,
                  status: 'Passed' }
    end

    it '1. Check creating new result with all other elements' do
      result = @user.create_new_result(@params)
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(@params[:result_set_name])
      expect(result.result_set.run.plan.product.name).to eq(@params[:product_name])
      expect(result.result_set.run.plan.name).to eq(@params[:plan_name])
      expect(result.result_set.run.name).to eq(@params[:run_name])
      expect(result.message).to eq(@params[:message])
      expect(result.status.name).to eq('Passed')
    end

    it '2. Check creating new result | only product has created before' do
      product = @user.create_new_product
      @params[:product_id] = product.id
      result = @user.create_new_result(@params)
      expect(result.result_set.run.plan.product.name).to eq(product.name)
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(@params[:result_set_name])
      expect(result.result_set.run.plan.name).to eq(@params[:plan_name])
      expect(result.result_set.run.name).to eq(@params[:run_name])
      expect(result.message).to eq(@params[:message])
      expect(result.status.name).to eq('Passed')
    end

    it '3. Check creating new result | only product and plan has created before' do
      plan = @user.create_new_plan(product_name: rand_product_name)
      @params[:plan_id] = plan.id
      result = @user.create_new_result(@params)
      expect(result.result_set.run.plan.name).to eq(plan.name)
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(@params[:result_set_name])
      expect(result.result_set.run.name).to eq(@params[:run_name])
      expect(result.message).to eq(@params[:message])
      expect(result.status.name).to eq('Passed')
    end

    it '4. Check creating new result | only product, plan and run has created before' do
      run = @user.create_new_run(plan_name: rand_plan_name,
                                 product_name: rand_product_name)
      @params[:run_id] = run.id
      result = @user.create_new_result(@params)
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(@params[:result_set_name])
      expect(result.result_set.run.name).to eq(run.name)
      expect(result.message).to eq(@params[:message])
      expect(result.status.name).to eq('Passed')
    end

    it '5. Check creating new result | only product, plan, run and result set has created before' do
      result_set = @user.create_new_result_set(plan_name: rand_plan_name,
                                               product_name: rand_product_name,
                                               run_name: rand_run_name)
      @params[:result_set_id] = result_set.id
      result = @user.create_new_result(@params)
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(result_set.name)
      expect(result.message).to eq(@params[:message])
      expect(result.status.name).to eq('Passed')
    end

    it '6. Create result from multiple creator' do
      run = @user.create_new_run(@params)
      names_array = [rand_result_set_name, rand_result_set_name, rand_result_set_name]
      result_set_array = names_array.map do |name|
        @user.create_new_result_set(run_id: run.id, name: name).id
      end
      message = rand_message
      result = @user.create_new_result(result_set_id: result_set_array,
                                       message: message,
                                       status: 'Passed')
      expect(result.response.code).to eq('200')
      (result.result_set.result_sets.map(&:name) & names_array).each do |name|
        expect((result.result_set.result_sets.map(&:name) & names_array).include?(name)).to be_truthy
      end
      expect(result.message).to eq(message)
      expect(result.status.name).to eq('Passed')
    end

    it '8. Create result by case id and plan id' do
      product = @user.create_new_product
      result = @user.create_new_result(plan_name: rand_plan_name,
                                       product_id: product.id,
                                       run_name: rand_run_name,
                                       result_set_name: rand_result_set_name,
                                       message: rand_message,
                                       status: 'Passed')
      plan = @user.create_new_plan(name: rand_plan_name, product_id: product.id)
      cases = @user.get_cases(id: result.result_set.run.plan.product.suite.id)

      result_response = @user.create_new_result(plan_id: plan.id,
                                                case_id: cases.cases.first.id,
                                                message: rand_message,
                                                status: 'Passed')
      expect(result_response.response.code).to eq('200')
      expect(result_response.is_null).to be_falsey
      expect(result_response.result_set.name).to eq(cases.cases.first.name)
      expect(result_response.result_set.run.plan.id).to eq(plan.id)
    end

    it '9. Check creating new result with + in name' do
      run = @user.create_new_run(plan_name: rand_plan_name, product_name: rand_product_name)
      result_set = @user.create_new_result_set(run_id: run.id, name: '123123 + 123123')
      result = @user.create_new_result(result_set_id: result_set.id,
                                       message: rand_message,
                                       status: 'Passed')
      expect(result.response.code).to eq('200')
      expect(result.is_null).to be_falsey
      expect(result.result_set.name).to eq('123123 + 123123')
    end

    it '10. Create result by array with name and run id' do
      product = @user.create_new_product
      result_sets = (1..3).to_a.map do
        @params[:result_set_name] += 'new'
        @user.create_new_result(@params)
      end
      plan = @user.create_new_plan(name: rand_plan_name, product_id: product.id)
      cases = @user.get_cases(id: result_sets[0].result_set.run.plan.product.suite.id)
      result = @user.create_new_result(plan_id: plan.id,
                                       case_id: cases.cases.map(&:id),
                                       message: rand_message,
                                       status: 'Passed')
      expect(result.response.code).to eq('200')
      expect(result.result_set.result_sets.count).to eq(3)
      expect(result.result_set.result_sets.map(&:name)).to eq(cases.cases.map(&:name))
      expect(result.is_null).to be_falsey
    end
  end

  describe 'Get results' do
    before do
      @params = { plan_name: rand_plan_name,
                  product_name: rand_product_name,
                  run_name: rand_run_name,
                  result_set_name: rand_result_set_name,
                  message: rand_message,
                  status: 'Passed' }
    end

    it 'get results by result_set_id' do
      run = @user.create_new_run(@params)
      result_set = @user.create_new_result_set(run_id: run.id,
                                               result_set_name: rand_result_set_name)
      result = @user.create_new_result(result_set_id: result_set.id, message: rand_message, status: 'Passed')
      result_pack = @user.get_results(id: result_set.id)
      expect(result_pack.results.count).to eq(1)
      expect(result_pack.results.first.id).to eq(result.id)
    end
  end

  describe 'Get result' do
    it 'get result for one result' do
      run = @user.create_new_run(plan_name: rand_plan_name, product_name: rand_product_name)
      result_set = @user.create_new_result_set(run_id: run.id,
                                               result_set_name: rand_result_set_name)
      message = rand_message
      @user.create_new_result(result_set_id: result_set.id,
                              message: message,
                              status: 'Passed')
      results_pack = @user.get_results(id: result_set.id)
      result = @user.get_result(results_pack.results.first.id)
      expect(result.id).to eq(results_pack.results.first.id)
      expect(result.message).to eq(message)
    end
  end

  describe 'New result custom parameters' do
    before do
      @params = { plan_name: rand_plan_name,
                  product_name: rand_product_name,
                  run_name: rand_run_name,
                  result_set_name: rand_result_set_name,
                  message: rand_message_custom_data,
                  status: 'Passed' }
    end

    it 'Create new result with custom parameters' do
      result_set = @user.create_new_result_set(plan_name: rand_plan_name,
                                               product_name: rand_product_name,
                                               run_name: rand_run_name)
      @params[:result_set_id] = result_set.id
      result = @user.create_new_result(@params)
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(result_set.name)
      expect(result.message).to eq(@params[:message])
      expect(result.status.name).to eq('Passed')
    end

    it 'Create new result with custom parameters number in value' do
      result_set = @user.create_new_result_set(plan_name: rand_plan_name,
                                               product_name: rand_product_name,
                                               run_name: rand_run_name)
      @params[:result_set_id] = result_set.id
      @params[:message] = rand_message_custom_with_numbers
      result = @user.create_new_result(@params)
      expect(result.response.code).to eq('200')
      expect(result.result_set.name).to eq(result_set.name)
      expect(result.message).to eq(@params[:message])
      expect(result.status.name).to eq('Passed')
    end
  end
end
