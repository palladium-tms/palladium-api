require_relative '../../tests/test_management'
http, account, run, result_set = nil
describe 'Result Smoke' do
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

    request = ResultSetFunctions.create_new_result_set(account.merge({"result_set_data[run_id]" => run['id']}))
    result_set = JSON.parse(http.request(request[0]).body)['result_set']
  end

  describe 'Create new result' do
    it 'check creating new result' do
      request = ResultFunctions.create_new_result(account.merge({"result_data[result_set_id]" => result_set['id']}))
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['result']['result_set_id']).to eq(result_set['id'])
    end

    it 'check creating new result without user_data' do
      request = ResultFunctions.create_new_result({"result_data[result_set_id]" => result_set['id']})
      response = http.request(request)
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'check creating new result with uncorrect result_set_id' do
      uncorrect_result_set_id = 30.times.map { StaticData::ALPHABET.sample }.join
      request = ResultFunctions.create_new_result(account.merge({"result_data[result_set_id]" => uncorrect_result_set_id}))
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']['result_set_id']).to eq([ErrorMessages::RESULT_SET_ID_WRONG])
    end

    it 'check creating new result with uncorrect result_set_id' do
      uncorrect_result_set_id = 30.times.map { StaticData::ALPHABET.sample }.join
      request = ResultFunctions.create_new_result(account.merge({"result_data[result_set_id]" => uncorrect_result_set_id}))
      response = http.request(request)
      expect(JSON.parse(response.body)['errors']['result_set_id']).to eq([ErrorMessages::RESULT_SET_ID_WRONG])
    end
  end
end