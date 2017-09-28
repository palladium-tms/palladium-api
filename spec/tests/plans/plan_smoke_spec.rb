require_relative '../../tests/test_management'
http, product, plan, plan_name = nil
describe 'Plan Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  before :each do
    #---product creating
    product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
  end

  describe 'Create new plan' do
    it 'check creating new plan with product_id' do
      correct_plan_name = http.random_name
      response = PlanFunctions.create_new_plan(http, plan_name: correct_plan_name,
                                                     product_id: product['id'])[0]
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['plan']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['plan']['name']).to eq(correct_plan_name)
      expect(JSON.parse(response.body)['plan']['product_id']).to eq(product['id'])
    end

    it 'check creating new plan with product_name(it product is exists)' do
      response, plan_name = PlanFunctions.create_new_plan(http, product_name: product['name'])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['plan']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['plan']['name']).to eq(plan_name)
      expect(JSON.parse(response.body)['plan']['product_id']).to eq(product['id'])
    end

    it 'check creating new plan with product_name(it product is not exists)' do
      product_name = http.random_name
      response, plan_name = PlanFunctions.create_new_plan(http, product_name: product_name)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['plan']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['plan']['name']).to eq(plan_name)
    end
  end

  describe 'Show plans' do
    before :each do
      plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
    end

    it 'get plans by product id' do
      response = PlanFunctions.get_plans(http, product_id: plan['product_id'])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']).to be_empty
      expect(JSON.parse(response.body)['plans'].count).to eq(1)
      expect(JSON.parse(response.body)['plans'][0]['name']).to eq(plan['name'])
      expect(JSON.parse(response.body)['plans'][0]['product_id']).to eq(plan['product_id'])
    end

    it 'get plans by product name' do
      response = PlanFunctions.get_plans(http, product_id: plan['product_id'])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']).to be_empty
      expect(JSON.parse(response.body)['plans'].count).to eq(1)
      expect(JSON.parse(response.body)['plans'][0]['name']).to eq(plan['name'])
      expect(JSON.parse(response.body)['plans'][0]['product_id']).to eq(product['id'])
    end

    it 'get one plan | show method' do
      plan_data = JSON.parse(PlanFunctions.create_new_plan(http, product_name: http.random_name)[0].body)
      res_plan = PlanFunctions.show_plan(http, id: plan_data['plan']['id'])
      expect(res_plan.code).to eq('200')
      expect(JSON.parse(res_plan.body)['plan']).to eq(plan_data['plan'])
    end
  end

  describe 'Delete Plan' do
    before :each do
      plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
    end

    it 'check deleting plan' do
      response = JSON.parse(PlanFunctions.delete_plan(http, id: plan['id']).body)
      plans = JSON.parse(PlanFunctions.get_plans(http, product_id: plan['product_id']).body)
      expect(response['errors'].empty?).to be_truthy
      expect(response['plan']).to eq(plan['id'].to_s)
      expect(plans['plans']).to be_empty
    end

    it 'check deleting plan with runs' do
      response, run_name = RunFunctions.create_new_run(http, plan_id: plan['id'])
      response = JSON.parse(PlanFunctions.delete_plan(http, id: plan['id']).body)
      plans = JSON.parse(PlanFunctions.get_plans(http, product_id: plan['product_id']).body)
      expect(response['errors'].empty?).to be_truthy
      expect(response['plan']).to eq(plan['id'].to_s)
      expect(plans['plans']).to be_empty
    end
  end

  describe 'Edit Plan' do
    it 'edit plan after create' do
      responce, name = PlanFunctions.create_new_plan(http, product_name: product['name'])
      plan_name_for_updating = http.random_name
      plan_id = JSON.parse(responce.body)['plan']['id']
      plan_new = JSON.parse(PlanFunctions.update_plan(http, id: plan_id, plan_name: plan_name_for_updating).body)
      expect(plan_new['errors'].empty?).to be_truthy
      expect(plan_new['plan_data']['id']).to eq(plan_id)
      expect(plan_new['plan_data']['name']).to eq(plan_name_for_updating)
    end
  end
end
