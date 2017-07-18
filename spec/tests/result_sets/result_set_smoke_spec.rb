require_relative '../../tests/test_management'
http, run_id, result_set, result_set_id, token = nil
describe 'Result Set Smoke' do
  before :each do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    token = AuthFunctions.create_user_and_get_token
  end

  describe 'Create new result_sets' do
    it '1. Create product, plan, run and result set in one time' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      request = ResultSetFunctions.create_new_result_set(token: token,
                                                         plan_name: plan_name,
                                                         run_name: run_name,
                                                         product_name: product_name,
                                                         result_set_name: result_set_name)
      responce = JSON.parse(http.request(request[0]).body)
      expect(responce['errors']).to be_empty
      expect(responce['result_set']['name']).to eq(result_set_name)
    end

    it '2. Create plan, run and result set in one time' do
      plan_name, run_name, result_set_name = Array.new(4).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      product = ProductFunctions.create_new_product(token)
      product_id = JSON.parse(http.request(product[0]).body)['product']['id']
      request = ResultSetFunctions.create_new_result_set(token: token,
                                                         plan_name: plan_name,
                                                         run_name: run_name,
                                                         product_id: product_id,
                                                         result_set_name: result_set_name)
      responce = JSON.parse(http.request(request[0]).body)
      expect(responce['errors']).to be_empty
      expect(responce['result_set']['name']).to eq(result_set_name)
    end

    it '3. Create run and result set in one time' do
      run_name, result_set_name = Array.new(4).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      product = ProductFunctions.create_new_product(token)
      product_id = JSON.parse(http.request(product[0]).body)['product']['id']

      plan = PlanFunctions.create_new_plan(token: token, product_id: product_id)
      plan_id = JSON.parse(http.request(plan[0]).body)['plan']['id']
      request = ResultSetFunctions.create_new_result_set(token: token,
                                                         plan_id: plan_id,
                                                         run_name: run_name,
                                                         result_set_name: result_set_name)
      responce = JSON.parse(http.request(request[0]).body)
      expect(responce['errors']).to be_empty
      expect(responce['result_set']['name']).to eq(result_set_name)
    end

    it '4. Create result set in one time' do
      run_name, result_set_name = Array.new(4).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      product = ProductFunctions.create_new_product(token)
      product_id = JSON.parse(http.request(product[0]).body)['product']['id']
      plan = PlanFunctions.create_new_plan(token: token, product_id: product_id)
      plan_id = JSON.parse(http.request(plan[0]).body)['plan']['id']
      run = RunFunctions.create_new_run(token: token, plan_id: plan_id, run_name: run_name)
      run_id = JSON.parse(http.request(run[0]).body)['run']['id']
      request = ResultSetFunctions.create_new_result_set(token: token,
                                                         run_id: run_id,
                                                         result_set_name: result_set_name)
      responce = JSON.parse(http.request(request[0]).body)
      expect(responce['errors']).to be_empty
      expect(responce['result_set']['name']).to eq(result_set_name)
    end
  end

  describe 'Show result_set' do
    before :each do
      product_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = ProductFunctions.create_new_product(token, product_name)[0]
      product_id = JSON.parse(http.request(request).body)['product']['id']

      plan_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = PlanFunctions.create_new_plan(token: token, product_id: product_id, plan_name: plan_name)[0]
      plan_id = JSON.parse(http.request(request).body)['plan']['id']

      run_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(token: token, plan_id: plan_id, run_name: run_name)
      run_id = JSON.parse(http.request(request[0]).body)['run']['id']

      result_set_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = ResultSetFunctions.create_new_result_set(token: token,
                                                         run_id: run_id,
                                                         result_set_name: result_set_name)
      result_set = JSON.parse(http.request(request[0]).body)
    end

    it 'get result_sets by run_id' do
      request = ResultSetFunctions.get_result_sets(token: token, id: run_id)
      result = JSON.parse(http.request(request).body)
      expect(result['errors'].empty?).to be_truthy
      expect(result['result_sets'].first['id']).to eq(result_set['result_set']['id'])
      expect(result['result_sets'].first['run_id']).to eq(result_set['result_set']['run_id'])
    end
  end

  describe 'Delete result_set' do
    before :each do
      product_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = ProductFunctions.create_new_product(token, product_name)[0]
      product_id = JSON.parse(http.request(request).body)['product']['id']

      plan_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = PlanFunctions.create_new_plan(token: token, product_id: product_id, plan_name: plan_name)[0]
      plan_id = JSON.parse(http.request(request).body)['plan']['id']

      run_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(token: token, plan_id: plan_id, run_name: run_name)
      run_id = JSON.parse(http.request(request[0]).body)['run']['id']

      result_set_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = ResultSetFunctions.create_new_result_set(token: token,
                                                         run_id: run_id,
                                                         result_set_name: result_set_name)
      result_set_id = JSON.parse(http.request(request[0]).body)['result_set']['id']
    end

    it 'Delete result set' do
      request = ResultSetFunctions.delete_result_set(token: token, id: result_set_id)
      result_set = JSON.parse(http.request(request).body)
      expect(result_set['result_set']['id']).to eq(result_set_id.to_s)
      request = ResultSetFunctions.get_result_sets(token: token, id: run_id)
      result = JSON.parse(http.request(request).body)
      expect(result['result_sets']).to be_empty
    end
  end

  describe 'Edit result_set' do
    before :each do
      product_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = ProductFunctions.create_new_product(token, product_name)[0]
      product_id = JSON.parse(http.request(request).body)['product']['id']

      plan_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = PlanFunctions.create_new_plan(token: token, product_id: product_id, plan_name: plan_name)[0]
      plan_id = JSON.parse(http.request(request).body)['plan']['id']

      run_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = RunFunctions.create_new_run(token: token, plan_id: plan_id, run_name: run_name)
      run_id = JSON.parse(http.request(request[0]).body)['run']['id']

      result_set_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = ResultSetFunctions.create_new_result_set(token: token,
                                                         run_id: run_id,
                                                         result_set_name: result_set_name)
      result_set_id = JSON.parse(http.request(request[0]).body)['result_set']['id']
    end

    it 'Edit result set' do
      new_result_set_name = Array.new(30) { StaticData::ALPHABET.sample }.join
      request = ResultSetFunctions.update_result_set(token: token, id: result_set_id, name: new_result_set_name)
      result_set = JSON.parse(http.request(request).body)['result_set_data']
      expect(result_set['id']).to eq(result_set_id)
      expect(result_set['name']).to eq(new_result_set_name)
      request = ResultSetFunctions.get_result_sets(token: token, id: run_id)
      result = JSON.parse(http.request(request).body)
      expect(result['result_sets'].first['name']).to eq(new_result_set_name)
    end
  end
end
