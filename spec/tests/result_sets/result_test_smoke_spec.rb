require_relative '../../tests/test_management'
http, account, plan = nil
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
  end
  describe 'Create new run' do
    it 'check creating new result sets' do
      request = RunFunctions.create_new_run(account.merge({"result_set_data[run_id]" => run['id']}))
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['run']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['run']['name']).to eq(request[1])
      expect(JSON.parse(response.body)['run']['plan_id']).to eq(plan['id'])
    end
  end
end