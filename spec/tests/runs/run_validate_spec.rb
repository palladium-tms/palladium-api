require_relative '../../tests/test_management'
http, plan, product = nil
describe 'Run Validation' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  before :each do
    #---plan creation
    product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
    plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
  end

  describe 'Create new run - empty name check' do
    it 'create run with empty product name' do
      product_name = http.random_name
      response = RunFunctions.create_new_run(http, plan_name: product_name,
                                                   product_name: '')[0]
      result = JSON.parse(response.body)
      expect(response.code).to eq('422')
      expect(result['run_errors']).to eq('product or plan creating error')
      expect(result['plan_errors']).to eq('product creating error')
      expect(result['product_errors']).to eq(['name cannot be empty'])
    end

    it 'create run with empty plan name' do
      plan_name = http.random_name
      response = RunFunctions.create_new_run(http, plan_name: '',
                                                   product_name: plan_name)[0]
      result = JSON.parse(response.body)
      expect(response.code).to eq('422')
      expect(result['run_errors']).to eq('product or plan creating error')
      expect(result['plan_errors']).to eq(['name cannot be empty'])
      expect(result['product_errors']).to be_nil
    end

    it 'create run with empty plan name and product name' do
      response = RunFunctions.create_new_run(http, plan_name: '',
                                                   product_name: '')[0]
      result = JSON.parse(response.body)
      expect(response.code).to eq('422')
      expect(result['run_errors']).to eq('product or plan creating error')
      expect(result['plan_errors']).to eq('product creating error')
      expect(result['product_errors']).to eq(['name cannot be empty'])
    end

    it 'create run with empty run name' do
      plan_name, product_name, = Array.new(2).map { http.random_name }
      response = RunFunctions.create_new_run(http, plan_name: plan_name,
                                                   product_name: product_name, name: '')[0]
      result = JSON.parse(response.body)
      expect(response.code).to eq('422')
      expect(result['run_errors']).to eq(['name cannot be empty'])
    end

    it 'create run without run name' do
      response = http.post_request('/api/run_new',
                                   run_data: { plan_id: plan['id'] })
      result = JSON.parse(response.body)
      expect(response.code).to eq('422')
      expect(result['run_errors']).to eq(['name cannot be empty'])
    end
  end

  describe 'Create new run - empty id check' do
    it 'create run with empty product id' do
      product_name = http.random_name
      response = RunFunctions.create_new_run(http, plan_name: product_name,
                                                   product_id: nil)[0]
      result = JSON.parse(response.body)
      expect(response.code).to eq('422')
      expect(result['product_errors']).to eq('product id of name not found')
    end

    it 'create run with without product id' do
      product_name = http.random_name
      response = RunFunctions.create_new_run(http, plan_name: product_name)[0]
      result = JSON.parse(response.body)
      expect(response.code).to eq('422')
      expect(result['product_errors']).to eq('product id of name not found')
    end

    it 'create run with empty plan id' do
      run_name = Array.new(2).map { http.random_name }[0]
      response = http.post_request('/api/run_new',
                                   run_data: { plan_id: nil, name: run_name })
      result = JSON.parse(response.body)
      expect(response.code).to eq('422')
      expect(result['product_errors']).to eq('product id of name not found')
    end

    it 'create run without plan id' do
      run_name = Array.new(2).map { http.random_name }[0]
      response = http.post_request('/api/run_new',
                                   run_data: { name: run_name })
      result = JSON.parse(response.body)
      expect(response.code).to eq('422')
      expect(result['product_errors']).to eq('product id of name not found')
    end
  end
end
