require_relative '../../tests/test_management'
describe 'Run Validation' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  before :each do
    @product = @user.create_new_product
    @plan = @user.create_new_plan(product_id: @product.id)
  end

  describe 'Create new run - empty name check' do
    it 'create run with empty product name' do
      run = @user.create_new_run(plan_name: rand_plan_name, product_name: '')
      result = JSON.parse(run.response.body)
      expect(run.response.code).to eq('422')
      expect(result['run_errors']).to eq('product or plan creating error')
      expect(result['plan_errors']).to eq('product creating error')
      expect(result['product_errors']).to eq(['name cannot be empty'])
    end

    it 'create run with empty plan name' do
      run = @user.create_new_run(plan_name: '', product_name: rand_plan_name)
      result = JSON.parse(run.response.body)
      expect(run.response.code).to eq('422')
      expect(result['run_errors']).to eq('product or plan creating error')
      expect(result['plan_errors']).to eq(['name cannot be empty'])
      expect(result['product_errors']).to be_nil
    end

    it 'create run with empty plan name and product name' do
      run = @user.create_new_run(plan_name: '', product_name: '')
      result = JSON.parse(run.response.body)
      expect(run.response.code).to eq('422')
      expect(result['run_errors']).to eq('product or plan creating error')
      expect(result['plan_errors']).to eq('product creating error')
      expect(result['product_errors']).to eq(['name cannot be empty'])
    end

    it 'create run with empty run name' do
      run = @user.create_new_run(plan_name: rand_plan_name, product_name: rand_product_name, name: '')
      result = JSON.parse(run.response.body)
      expect(run.response.code).to eq('422')
      expect(result['run_errors']).to eq(['name cannot be empty'])
    end

    it 'create run without run name' do
      run = @user.post_request('/api/run_new',
                              run_data: { plan_id: @plan.id })
      result = JSON.parse(run.response.body)
      expect(run.response.code).to eq('422')
      expect(result['run_errors']).to eq(['name cannot be empty'])
    end
  end

  describe 'Create new run - empty id check' do
    it 'create run with empty product id' do
      run = @user.create_new_run(plan_name: rand_product_name, product_id: nil)
      result = JSON.parse(run.response.body)
      expect(run.response.code).to eq('422')
      expect(result['product_errors']).to eq('product id of name not found')
    end

    it 'create run with without product id' do
      run = @user.create_new_run(plan_name: rand_run_name)
      result = JSON.parse(run.response.body)
      expect(run.response.code).to eq('422')
      expect(result['product_errors']).to eq('product id of name not found')
    end

    it 'create run with empty plan id' do
      run = @user.post_request('/api/run_new', run_data: { plan_id: nil, name: rand_run_name })
      result = JSON.parse(run.response.body)
      expect(run.response.code).to eq('422')
      expect(result['product_errors']).to eq('product id of name not found')
    end

    it 'create run without plan id' do
      response = @user.post_request('/api/run_new', run_data: { name: rand_run_name })
      result = JSON.parse(response.body)
      expect(response.code).to eq('422')
      expect(result['product_errors']).to eq('product id of name not found')
    end
  end
end
