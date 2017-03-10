require_relative '../../tests/test_management'
http, account, result_set = nil
describe 'Status Functional' do
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

    it 'check creating new status if trying to create result with not existing status' do
      status_name = 30.times.map {StaticData::ALPHABET.sample }.join
      request = ResultFunctions.create_new_result(account.merge({"result_data[result_set_id]" => result_set['id'],
                                                                 "result_data[status]" => status_name}))
      response = http.request(request)
      all_statuses = StatusFunctions.get_all_statuses(account)
      expect(response.code).to eq('200')
      expect(all_statuses.select {|_, status| status['name'] == status_name }.empty?).to be_falsey
    end
end