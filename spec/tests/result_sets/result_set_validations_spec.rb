require_relative '../../tests/test_management'
describe 'Result Set Validations' do
  before :each do
    @user = AccountFunctions.create_and_parse
    @user.login
    @params = {plan_name: rand_plan_name,
               product_name: rand_product_name,
               run_name: rand_run_name,
               name: rand_result_set_name,
               message: rand_message,
               status: 'Passed'}
  end

  describe 'Create new result_sets' do
    it 'creating result_set with empty product name' do
      @params[:product_name] = ''
      result_set = @user.create_new_result_set(@params)
      response = JSON.parse(result_set.response.body)
      expect(response['run_errors']).to eq('product or plan creating error')
      expect(response['plan_errors']).to eq('product creating error')
      expect(response['product_errors']).to eq(['name cannot be empty'])
      expect(result_set.errors).to eq('product, plan or run creating error')
    end

    it 'creating result_set with empty plan name' do
      @params[:plan_name] = ''
      result_set = @user.create_new_result_set(@params)
      response = JSON.parse(result_set.response.body)
      expect(response['run_errors']).to eq('product or plan creating error')
      expect(response['plan_errors']).to eq(['name cannot be empty'])
      expect(result_set.errors).to eq('product, plan or run creating error')
    end

    it 'creating result_set with empty run name' do
      @params[:run_name] = ''
      result_set = @user.create_new_result_set(@params)
      responce = JSON.parse(result_set.response.body)
      expect(responce['run_errors']).to eq(['name cannot be empty'])
      expect(result_set.errors).to eq('product, plan or run creating error')
    end

    it 'creating result_set with empty result_set_name name' do
      @params[:name] = ''
      result_set = @user.create_new_result_set(@params)
      expect(result_set.errors).to eq([['name cannot be empty']])
    end
  end
end
