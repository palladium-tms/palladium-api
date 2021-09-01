require_relative '../../tests/test_management'
describe 'Get result sets by status' do
  before do
    @user = AccountFunctions.create_and_parse
    @user.login
    @params = { plan_name: rand_plan_name,
                product_name: rand_product_name,
                run_name: rand_run_name,
                result_set_name: rand_result_set_name,
                message: rand_message,
                status: 'Passed' }
  end

  it 'get result_sets by status' do
    @user.token = @user.create_new_api_token.token
    result_first = @user.create_new_result(@params)
    @params[:result_set_name] += '1'
    result_second = @user.create_new_result(@params)
    @params[:result_set_name] += '2'
    @user.create_new_result(@params)
    @params[:status] = 'Failed'
    @user.create_new_result(@params)
    result_set_pack = @user.get_result_sets_by_status(plan_name: @params[:plan_name],
                                                      run_name: @params[:run_name],
                                                      product_name: @params[:product_name],
                                                      status: 'Passed')
    expect(result_set_pack).to be_contain(result_first.result_set)
    expect(result_set_pack).to be_contain(result_second.result_set)
  end

  it 'get result_sets by status if it not found' do
    @user.token = @user.create_new_api_token.token
    @user.create_new_result(@params)
    result_sets_pack = @user.get_result_sets_by_status(plan_name: @params[:plan_name],
                                                       run_name: @params[:run_name],
                                                       product_name: @params[:product_name],
                                                       status: 'Failed')
    expect(result_sets_pack.result_sets).to be_empty
  end

  describe 'Incorrect data' do
    before do
      @user.token = @user.create_new_api_token.token
    end

    it 'getting result_set_by_status with incorrect product_name' do
      result_set_pack = @user.get_result_sets_by_status(product_name: 'incorrect_product_name',
                                                        plan_name: rand_plan_name,
                                                        run_name: rand_run_name,
                                                        result_set_name: rand_result_set_name,
                                                        status: 'Passed')
      expect(result_set_pack.result_sets).to be_empty
      expect(result_set_pack.parsed_body['product_errors']).to eq('product not found')
    end

    it 'getting result_set_by_status with incorrect plan name' do
      @user.create_new_result(@params)
      result_set_pack = @user.get_result_sets_by_status(product_name: @params[:product_name],
                                                        plan_name: 'incorrect_plan_name',
                                                        run_name: @params[:run_name],
                                                        status: 'Passed')
      expect(result_set_pack.result_sets).to be_empty
      expect(result_set_pack.parsed_body['plan_errors']).to eq('plan not found')
    end

    it 'getting result_set_by_status with incorrect run name' do
      @user.create_new_result(@params)
      result_set_pack = @user.get_result_sets_by_status(product_name: @params[:product_name],
                                                        plan_name: @params[:plan_name],
                                                        run_name: 'incorrect_run_name',
                                                        status: 'Passed')
      expect(result_set_pack.result_sets).to be_empty
      expect(result_set_pack.parsed_body['run_errors']).to eq('run not found')
    end

    it 'getting result_set_by_status with incorrect status name' do
      @user.create_new_result(@params)
      result_set_pack = @user.get_result_sets_by_status(product_name: @params[:product_name],
                                                        plan_name: @params[:plan_name],
                                                        run_name: @params[:run_name],
                                                        status: 'incorrect_status')
      expect(result_set_pack.result_sets).to be_empty
      expect(result_set_pack.parsed_body['status_errors']).to eq('status not found')
    end
  end

  it 'get result_sets by statuses(multiple)' do
    @user.token = @user.create_new_api_token.token
    statuses = %w[Passed Failed]
    result_first = @user.create_new_result(@params)
    @params[:status] = 'Failed'
    @params[:result_set_name] = rand_result_set_name
    result_second = @user.create_new_result(@params)
    @params[:status] = 'Pending'
    @params[:result_set_name] = rand_result_set_name
    @user.create_new_result(@params)
    @params[:status] = 'Aborted'
    @params[:result_set_name] = rand_result_set_name
    @user.create_new_result(@params)
    result_sets_pack = @user.get_result_sets_by_status(plan_name: @params[:plan_name],
                                                       run_name: @params[:run_name],
                                                       product_name: @params[:product_name],
                                                       status: statuses)
    expect(result_sets_pack.result_sets.count).to eq(2)
    expect(result_sets_pack).to be_contain(result_first.result_set)
    expect(result_sets_pack).to be_contain(result_second.result_set)
  end
end
