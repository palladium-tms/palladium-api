require_relative '../../tests/test_management'
http, product_name, plan_name, run_name, result_set_name, message = nil
describe 'Get result sets by status' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
    token = JSON.parse(TokenFunctions.create_new_api_token(http).body)['token_data']['token']
    http = Http.new(token: token)
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
                                                           status: status)
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
                                                            status: status)
    result_sets = ResultSetFunctions.get_result_sets_by_status(http, plan_name: plan_name,
                                                                     run_name: run_name,
                                                                     product_name: product_name,
                                                                     status: status)
    body = JSON.parse(result_sets.body)
    expect(body['product']['name']).to eq(product_name)
    expect(body['plan']['name']).to eq(plan_name)
    expect(body['run']['name']).to eq(run_name)
    expect(body['status'][0]['name']).to eq(status)
    expect(body['result_sets'].count).to eq(2)
    expect(body['result_sets'].include?(JSON.parse(result_first.body)['result_sets'][0])).to be_truthy
    expect(body['result_sets'].include?(JSON.parse(result_second.body)['result_sets'][0])).to be_truthy
  end

  it 'get result_sets by status if it not found' do
    status = 'Passed'
    ResultFunctions.create_new_result(http, plan_name: plan_name,
                                            run_name: run_name,
                                            product_name: product_name,
                                            result_set_name: result_set_name,
                                            message: message,
                                            status: 'Failed')
    result_sets = ResultSetFunctions.get_result_sets_by_status(http, plan_name: plan_name,
                                                                     run_name: run_name,
                                                                     product_name: product_name,
                                                                     result_set_name: result_set_name,
                                                                     status: status)
    body = JSON.parse(result_sets.body)
    expect(body['product']['name']).to eq(product_name)
    expect(body['plan']['name']).to eq(plan_name)
    expect(body['run']['name']).to eq(run_name)
    expect(body['status'][0]['name']).to eq(status)
    expect(body['result_sets']).to eq([])
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
      result_sets = ResultSetFunctions.get_result_sets_by_status(http, product_name: 'incorrect_product_name',
                                                                       plan_name: plan_name,
                                                                       run_name: run_name,
                                                                       result_set_name: result_set_name,
                                                                       status: 'Passed')
      body = JSON.parse(result_sets.body)
      expect(body['product']).to be_nil
      expect(body['product_errors']).to eq('product not found')
    end

    it 'getting result_set_by_status with incorrect plan name' do
      result_sets = ResultSetFunctions.get_result_sets_by_status(http, product_name: product_name,
                                                                       plan_name: 'incorrect_plan_name',
                                                                       run_name: run_name,
                                                                       status: 'Passed')
      body = JSON.parse(result_sets.body)
      expect(body['product']['name']).to eq(product_name)
      expect(body['plan']).to be_nil
      expect(body['plan_errors']).to eq('plan not found')
    end

    it 'getting result_set_by_status with incorrect run name' do
      result_sets = ResultSetFunctions.get_result_sets_by_status(http, product_name: product_name,
                                                                       plan_name: plan_name,
                                                                       run_name: 'incorrect_run_name',
                                                                       status: 'Passed')
      body = JSON.parse(result_sets.body)
      expect(body['product']['name']).to eq(product_name)
      expect(body['plan']['name']).to eq(plan_name)
      expect(body['run']).to be_nil
      expect(body['run_errors']).to eq('run not found')
    end

    it 'getting result_set_by_status with incorrect status name' do
      result_sets = ResultSetFunctions.get_result_sets_by_status(http, product_name: product_name,
                                                                       plan_name: plan_name,
                                                                       run_name: run_name,
                                                                       status: 'incorrect_status')
      body = JSON.parse(result_sets.body)
      expect(body['product']['name']).to eq(product_name)
      expect(body['plan']['name']).to eq(plan_name)
      expect(body['run']['name']).to eq(run_name)
      expect(body['status']).to be_nil
      expect(body['status_errors']).to eq('status not found')
    end
  end

  it 'get result_sets by statuses(multiple)' do
    statuses = %w[Passed Failed]
    result_first = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                           run_name: run_name,
                                                           product_name: product_name,
                                                           result_set_name: result_set_name + 'important_1',
                                                           message: message,
                                                           status: 'Passed')
    result_second = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                            run_name: run_name,
                                                            product_name: product_name,
                                                            result_set_name: result_set_name + 'important_2',
                                                            message: message,
                                                            status: 'Failed')
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
    result_sets = ResultSetFunctions.get_result_sets_by_status(http, plan_name: plan_name,
                                                                     run_name: run_name,
                                                                     product_name: product_name,
                                                                     status: statuses)
    body = JSON.parse(result_sets.body)
    expect(body['product']['name']).to eq(product_name)
    expect(body['plan']['name']).to eq(plan_name)
    expect(body['run']['name']).to eq(run_name)
    expect(body['status'].count).to eq(2)
    expect(body['status'].map { |obj| obj['name'] }.include?(statuses[1])).to be_truthy
    expect(body['status'].map { |obj| obj['name'] }.include?(statuses[0])).to be_truthy
    expect(body['result_sets'].count).to eq(2)
    expect(body['result_sets'].include?(JSON.parse(result_first.body)['result_sets'][0])).to be_truthy
    expect(body['result_sets'].include?(JSON.parse(result_second.body)['result_sets'][0])).to be_truthy
  end
end
