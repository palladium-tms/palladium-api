require_relative '../../tests/test_management'
http, account, product, plan, plan_name = nil
describe 'Plan Smoke' do
  before :all do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
  end

  before :each do
    #---product creating
    product = ProductFunctions.create_new_product(StaticData::TOKEN)
    http.request(product[0])
    product = JSON.parse(http.request(product[0]).body)['product']
  end

  describe 'Create new plan' do
    it 'check creating new plan with product_id' do
      request = Net::HTTP::Post.new('/api/plan_new','Authorization' => StaticData::TOKEN)
      corrent_plan_name = 30.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({"plan_data[name]": corrent_plan_name, "plan_data[product_id]": product['id']})
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['plan']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['plan']['name']).to eq(corrent_plan_name)
      expect(JSON.parse(response.body)['plan']['product_id']).to eq(product['id'])
    end

    it 'check creating new plan with product_name(it product is exists)' do
      request, plan_name = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_id: product['id'])
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['plan']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['plan']['name']).to eq(plan_name)
      expect(JSON.parse(response.body)['plan']['product_id']).to eq(product['id'])
    end

    it 'check creating new plan with product_name(it product is not exists)' do
      request, plan_name = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_name: product['name'])
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['plan']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['plan']['name']).to eq(plan_name)
      expect(JSON.parse(response.body)['plan']['product_id']).to eq(product['id'])
    end
  end

  describe 'Show plans' do
    before :each do
      request = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_id: product['id'])[0]
      plan = JSON.parse(http.request(request).body)['plan']
    end

    it 'get plans by product id' do
      request = PlanFunctions.get_plans(token: StaticData::TOKEN, product_id: product['id'])
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']).to be_empty
      expect(JSON.parse(response.body)['plans'].count).to eq(1)
      expect(JSON.parse(response.body)['plans'][0]['name']).to eq(plan['name'])
      expect(JSON.parse(response.body)['plans'][0]['product_id']).to eq(product['id'])
    end

    it 'get plans by product name' do
      request = PlanFunctions.get_plans(token: StaticData::TOKEN, product_name: product['name'])
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']).to be_empty
      expect(JSON.parse(response.body)['plans'].count).to eq(1)
      expect(JSON.parse(response.body)['plans'][0]['name']).to eq(plan['name'])
      expect(JSON.parse(response.body)['plans'][0]['product_id']).to eq(product['id'])
    end
  end

  describe 'Delete Plan' do
    before :each do
      request = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_id: product['id'])[0]
      plan = JSON.parse(http.request(request).body)['plan']
    end

    it 'check deleting plan' do
      request = PlanFunctions.delete_plan(token: StaticData::TOKEN, id: plan['id'])
      response = JSON.parse(http.request(request).body)

      get_plans_req = PlanFunctions.get_plans(token: StaticData::TOKEN, product_id: product['id'])
      plans = JSON.parse(http.request(get_plans_req).body)
      expect(response['errors'].empty?).to be_truthy
      expect(response['plan']).to eq(plan['id'].to_s)
      expect(plans['plans']).to be_empty
    end
  end

  describe 'Edit Plan' do
    before :each do
      request = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_id: product['id'])[0]
      plan = JSON.parse(http.request(request).body)['plan']
    end

    it 'edit plan after create' do
      new_plan_name = 30.times.map { StaticData::ALPHABET.sample }.join
      request = PlanFunctions.update_plan({token: StaticData::TOKEN, id: plan['id'], name: new_plan_name})
      result = JSON.parse(http.request(request).body)
      expect(result['errors'].empty?).to be_truthy
      expect(result['plan_data']['id']).to eq(plan['id'])
      expect(result['plan_data']['name']).to eq(new_plan_name)
    end
  end
end