require_relative '../../tests/test_management'
http, account, run, result_set = nil
describe 'Result Set Functional' do
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
  describe 'Add result to result set' do
    before :each do
      request = ResultSetFunctions.create_new_result_set(account.merge({"result_set_data[run_id]" => run['id']}))
      result_set = JSON.parse(http.request(request[0]).body)['result_set']
    end

    it 'check creating new result_sets | result set status = last result status' do
      status_name = 30.times.map { StaticData::ALPHABET.sample }.join
      request = ResultFunctions.create_new_result(account.merge({"result_data[result_set_id]" => result_set['id'],
                                                                 "result_data[status]" => status_name}))
      result = JSON.parse(http.request(request).body)['result']
      result_sets = ResultSetFunctions.get_result_sets(account.merge("result_set_data[run_id]" => run['id']))
      expect(result_sets.map{|_, result_set| result_set['status'] == result['status_id']}.empty?).to be_falsey
    end
  end
end