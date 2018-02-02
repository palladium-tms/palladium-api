require_relative '../../tests/test_management'
http, product = nil
describe 'Plan Validation' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Create new plan and product' do
    it 'Create product and plan one command with empty product name' do
      correct_plan_name = http.random_name
      response = PlanFunctions.create_new_plan(http, name: correct_plan_name,
                                                     product_name: '')[0]
      expect(response.code).to eq('422')
      expect(JSON.parse(response.body)['plan_errors']).to eq('product creating error')
      expect(JSON.parse(response.body)['product_errors']).not_to be_empty
    end

    it 'Create product and plan one command with empty plan name' do
      correct_product_name = http.random_name
      response = PlanFunctions.create_new_plan(http, name: '',
                                                     product_name: correct_product_name)[0]
      expect(response.code).to eq('422')
      expect(JSON.parse(response.body)['plan_errors']).to eq(['name cannot be empty'])
    end

    it 'Create product and plan one command with empty plan name and product name' do
      correct_product_name = http.random_name
      response = PlanFunctions.create_new_plan(http, name: '',
                                                     product_name: '')[0]
      expect(response.code).to eq('422')
      response = JSON.parse(response.body)
      expect(response['plan_errors']).to eq('product creating error')
      expect(response['product_errors']).to eq(['name cannot be empty'])
    end

    it 'Create product and plan with spaces name' do
      correct_product_name = http.random_name
      response = PlanFunctions.create_new_plan(http, name: '   ',
                                                     product_name: '   ')[0]
      expect(response.code).to eq('422')
      response = JSON.parse(response.body)
      expect(response['plan_errors']).to eq('product creating error')
      expect(response['product_errors']).to eq(['name cannot contains only spaces'])
    end
  end

  describe 'Edit plan validation' do
    it 'Change plan name to empty' do
      response, plan_name = PlanFunctions.create_new_plan(http, product_name: http.random_name)
      response = JSON.parse(response.body)
      plan_new = PlanFunctions.update_plan(http, id: response['plan']['id'], plan_name: '').body
      expect(JSON.parse(plan_new)['plan_errors']).to eq(['name cannot be empty'])
    end
  end
end
