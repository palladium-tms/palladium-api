require_relative '../../tests/test_management'
http, product_name, plan_name, run_name, result_set_name, message = nil
describe 'Get result sets by status' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
    token = TokenFunctions.create_new_api_token(http)
    http = Http.new(token: token.token)
    product_name = 'Product_' + http.random_name
    plan_name = 'Plan_' + http.random_name
    run_name = 'Run_' + http.random_name
    result_set_name = 'Result_set_' + http.random_name
  end

  it 'get result_sets by status' do
    status = 'Passed'
    result_first = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                           run_name: run_name,
                                                           product_name: product_name,
                                                           result_set_name: result_set_name + '1',
                                                           message: message,
                                                           status: status)[0]
    ResultFunctions.create_new_result(http, plan_name: plan_name,
                                            run_name: run_name,
                                            product_name: product_name,
                                            result_set_name: result_set_name + '2',
                                            message: message,
                                            status: 'Failed')
    result_second = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                            run_name: run_name,
                                                            product_name: product_name,
                                                            result_set_name: result_set_name,
                                                            message: message,
                                                            status: status)[0]
    result_set_pack = ResultSetFunctions.get_result_sets_by_status(http, plan_name: plan_name,
                                                                     run_name: run_name,
                                                                     product_name: product_name,
                                                                     status: status)
    expect(result_set_pack.contain?(result_first.result_set)).to be_truthy
    expect(result_set_pack.contain?(result_second.result_set)).to be_truthy
  end

  it 'get result_sets by status if it not found' do
    status = 'Passed'
    ResultFunctions.create_new_result(http, plan_name: plan_name,
                                            run_name: run_name,
                                            product_name: product_name,
                                            result_set_name: result_set_name,
                                            message: message,
                                            status: 'Failed')
    result_sets_pack = ResultSetFunctions.get_result_sets_by_status(http, plan_name: plan_name,
                                                                     run_name: run_name,
                                                                     product_name: product_name,
                                                                     result_set_name: result_set_name,
                                                                     status: status)
    expect(result_sets_pack.result_sets).to be_empty
  end

  describe 'Incorrect data' do

    before :each do
      ResultFunctions.create_new_result(http, plan_name: plan_name,
                                              run_name: run_name,
                                              product_name: product_name,
                                              result_set_name: result_set_name + '1',
                                              message: message,
                                              status: 'Passed')
      ResultFunctions.create_new_result(http, plan_name: plan_name,
                                              run_name: run_name,
                                              product_name: product_name,
                                              result_set_name: result_set_name + '2',
                                              message: message,
                                              status: 'Failed')
    end

    it 'getting result_set_by_status with incorrect product name' do
      result_set_pack = ResultSetFunctions.get_result_sets_by_status(http, product_name: 'incorrect_product_name',
                                                                       plan_name: plan_name,
                                                                       run_name: run_name,
                                                                       result_set_name: result_set_name,
                                                                       status: 'Passed')
      expect(result_set_pack.result_sets).to be_empty
      expect(result_set_pack.parsed_body['product_errors']).to eq('product not found')
    end

    it 'getting result_set_by_status with incorrect plan name' do
      result_set_pack = ResultSetFunctions.get_result_sets_by_status(http, product_name: product_name,
                                                                       plan_name: 'incorrect_plan_name',
                                                                       run_name: run_name,
                                                                       status: 'Passed')
      expect(result_set_pack.result_sets).to be_empty
      expect(result_set_pack.parsed_body['plan_errors']).to eq('plan not found')
    end

    it 'getting result_set_by_status with incorrect run name' do
      result_set_pack = ResultSetFunctions.get_result_sets_by_status(http, product_name: product_name,
                                                                       plan_name: plan_name,
                                                                       run_name: 'incorrect_run_name',
                                                                       status: 'Passed')
      expect(result_set_pack.result_sets).to be_empty
      expect(result_set_pack.parsed_body['run_errors']).to eq('run not found')
    end

    it 'getting result_set_by_status with incorrect status name' do
      result_set_pack = ResultSetFunctions.get_result_sets_by_status(http, product_name: product_name,
                                                                       plan_name: plan_name,
                                                                       run_name: run_name,
                                                                       status: 'incorrect_status')
      expect(result_set_pack.result_sets).to be_empty
      expect(result_set_pack.parsed_body['status_errors']).to eq('status not found')
    end
  end

  it 'get result_sets by statuses(multiple)' do
    statuses = %w[Passed Failed]
    result_first = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                           run_name: run_name,
                                                           product_name: product_name,
                                                           result_set_name: result_set_name + 'important_1',
                                                           message: message,
                                                           status: 'Passed')[0]
    result_second = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                            run_name: run_name,
                                                            product_name: product_name,
                                                            result_set_name: result_set_name + 'important_2',
                                                            message: message,
                                                            status: 'Failed')[0]
    ResultFunctions.create_new_result(http, plan_name: plan_name,
                                            run_name: run_name,
                                            product_name: product_name,
                                            result_set_name: result_set_name,
                                            message: message,
                                            status: 'Pending')
    ResultFunctions.create_new_result(http, plan_name: plan_name,
                                            run_name: run_name,
                                            product_name: product_name,
                                            result_set_name: result_set_name,
                                            message: message,
                                            status: 'Aborted')
    result_sets_pack = ResultSetFunctions.get_result_sets_by_status(http, plan_name: plan_name,
                                                                     run_name: run_name,
                                                                     product_name: product_name,
                                                                     status: statuses)
    expect(result_sets_pack.result_sets.count).to eq(2)
    expect(result_sets_pack.contain?(result_first.result_set)).to be_truthy
    expect(result_sets_pack.contain?(result_second.result_set)).to be_truthy
  end
end
