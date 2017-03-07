require_relative '../../tests/test_management'
http, account, run, result_set = nil
describe 'Result Set Smoke' do
  before :each do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    request = AuthFunctions.create_new_account
    http.request(request[0])
    account = request[1]

    product = ProductFunctions.create_new_product(account)
    product_id = JSON.parse(http.request(product[0]).body)['product']['id']

    account = {"user_data[email]": account[:email], "user_data[password]": account[:password]}

    plan_request = PlanFunctions.create_new_plan(account.merge({"plan_data[product_id]" => product_id}))
    plan = JSON.parse(http.request(plan_request[0]).body)['plan']

    request = RunFunctions.create_new_run(account.merge({"run_data[plan_id]" => plan['id']}))
    run = JSON.parse(http.request(request[0]).body)['run']
  end

  describe 'Create new result_sets' do
    it 'check creating new result_sets' do
      request = ResultSetFunctions.create_new_result_set(account.merge({"result_set_data[run_id]" => run['id'],
                                                                        "result_set_data[status]" => 0}))
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['result_set']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['result_set']['name']).to eq(request[1])
      expect(JSON.parse(response.body)['result_set']['run_id']).to eq(run['id'])
      expect(JSON.parse(response.body)['result_set']['status']).to eq(0)
    end

    it 'check creating new result sets without user_data' do
      request = ResultSetFunctions.create_new_result_set({"result_set_data[run_id]" => run['id'],
                                                          "result_set_data[status]" => 0})
      response = http.request(request[0])
      expect(response.code).to eq('201')
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'check creating new result sets_with uncorrect run_id' do
      uncorrect_run_id = 30.times.map { StaticData::ALPHABET.sample }.join
      request = ResultSetFunctions.create_new_result_set(account.merge({"result_set_data[run_id]" => uncorrect_run_id,
                                                                        "result_set_data[status]" => 0}))
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].count).to eq(1)
      expect(JSON.parse(response.body)['errors']['run_id']).to eq([ErrorMessages::RUN_ID_WRONG])
    end

    it 'check creating new result_sets with uncorrect retult_set name | nil' do
      request = ResultSetFunctions.create_new_result_set(account.merge({"result_set_data[run_id]" => run['id'],
                                                                        "result_set_data[name]" => '',
                                                                        "result_set_data[status]" => 0}))
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']['name']).to eq([ErrorMessages::CANT_BE_EMPTY_RUN_NAME])
    end

    it 'check creating ng new result_sets with correct status' do
      request = ResultSetFunctions.create_new_result_set(account.merge({"result_set_data[run_id]" => run['id'],
                                                                        "result_set_data[status]" => 1}))
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['result_set']['status']).to eq(1)
      expect(JSON.parse(response.body)['result_set']['name']).to eq(request[1])
    end

    it 'check creating ng new result_sets with uncorrect status | string' do
      request = ResultSetFunctions.create_new_result_set(account.merge({"result_set_data[run_id]" => run['id'],
                                                                        "result_set_data[status]" => 'wqeqweqeqwe'}))
      response = http.request(request[0])
      expect(JSON.parse(response.body)['errors']['status']).to eq([ErrorMessages::IN_NOT_NUMBER_RESULT_SET_STATUS])
    end
  end

  describe 'ResultSets show' do
    before :each do
      result_set_request = ResultSetFunctions.create_new_result_set(account.merge({"result_set_data[run_id]" => run['id'],
                                                                                   "result_set_data[status]" => 0}))
      result_set = JSON.parse(http.request(result_set_request[0]).body)['result_set']
    end

    it 'get result_sets by run_id' do
      result = ResultSetFunctions.get_result_sets(account.merge({"result_set_data[run_id]" => run['id']}))
      expect(result[result_set['id']]['id']).to eq(result_set['id'])
      expect(result[result_set['id']]['run_id']).to eq(run['id'])
    end

    it 'get result_sets by run_id with uncorrect user_data' do
      result = ResultSetFunctions.get_result_sets({"result_set_data[run_id]" => run['id']})
      expect(result['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'get result_sets by run_id with uncorrect result_set_data | run_id' do
      uncorrect_run_id = 30.times.map { StaticData::ALPHABET.sample }.join
      result = ResultSetFunctions.get_result_sets(account.merge({"result_set_data[run_id]" => uncorrect_run_id}))
      expect(result['errors']['run_id']).to eq([ErrorMessages::RUN_ID_WRONG])
    end

    it 'get result_sets by run_id with uncorrect result_set_data | run_id is empty' do
      result = ResultSetFunctions.get_result_sets(account.merge({"result_set_data[run_id]" => ''}))
      expect(result['errors']['run_id']).to eq([ErrorMessages::RUN_ID_CANT_BE_EMPTY])
    end
  end
end