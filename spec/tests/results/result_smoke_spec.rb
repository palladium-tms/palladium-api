require_relative '../../tests/test_management'
http = nil
describe 'Result Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Create new result' do
    it '1. Check creating new result with all other elements' do
      product_name, plan_name, run_name, result_set_name, message = Array.new(5).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      response = ResultFunctions.create_new_result(http,{ plan_name: plan_name,
                                                  run_name: run_name,
                                                  product_name: product_name,
                                                  result_set_name: result_set_name,
                                                  message: message,
                                                  status: 'Passed' })
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['run_id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['result_set_id'].nil?).to be_falsey
    end

    it '2. Check creating new result | only product has created before' do
      product_id = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']['id']
      plan_name, run_name, result_set_name, message = Array.new(5).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      response = ResultFunctions.create_new_result(http,{ plan_name: plan_name,
                                                          run_name: run_name,
                                                          product_id: product_id,
                                                          result_set_name: result_set_name,
                                                          message: message,
                                                          status: 'Passed' })
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
    end

    it '3. Check creating new result | only product and plan has created before' do
      product_id = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']['id']
      plan_id = JSON.parse(PlanFunctions.create_new_plan(http, {product_id: product_id})[0].body)['plan']['id']
      run_name, result_set_name, message = Array.new(5).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      response = ResultFunctions.create_new_result(http,
                                                  { plan_id: plan_id,
                                                  run_name: run_name,
                                                  result_set_name: result_set_name,
                                                  message: message,
                                                  status: 'Passed'})
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
    end

    it '4. Check creating new result | only product, plan and run has created before' do
      result_set_name, message = Array.new(5).map { Array.new(30) { http.random_name }.join }
      run_id = JSON.parse(RunFunctions.create_new_run(http, {plan_name: http.random_name})[0].body)['run']['id']
      response = ResultFunctions.create_new_result(http,{run_id: run_id,
                                                  result_set_name: result_set_name,
                                                  message: message,
                                                  status: 'Passed' })
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
    end

    it '5. Check creating new result | only product, plan, run and result set has created before' do
      result_set_name, message = Array.new(5).map { Array.new(30) { http.random_name }.join }
      run_id = JSON.parse(RunFunctions.create_new_run(http, {plan_name: http.random_name})[0].body)['run']['id']
      result_set_id = JSON.parse(ResultSetFunctions.create_new_result_set(http, {run_id: run_id,
                                                                              result_set_name: result_set_name})[0].body)['result_set']['id']
      response = ResultFunctions.create_new_result(http,
                                                  { result_set_id: result_set_id,
                                                  message: message,
                                                  status: 'Passed' })
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['result_set_id']).to eq([result_set_id])
    end

    # You can send array of result_sets for create this result for every this result_sets
    it '6. Create result from multiple creator' do
      result_set_name, message = Array.new(5).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      run_id = JSON.parse(RunFunctions.create_new_run(http, {plan_name: http.random_name})[0].body)['run']['id']
      result_set_array = (1..3).to_a.map do |iterator|
        JSON.parse(ResultSetFunctions.create_new_result_set(http,
                                                            run_id: run_id,
                                                            result_set_name: result_set_name + iterator.to_s)[0].body)['result_set']['id']
      end

      response = ResultFunctions.create_new_result(http,
                                                  result_set_id: result_set_array,
                                                  message: message,
                                                  status: 'Passed')
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['result_set_id']).to eq(result_set_array)
    end
  end

  describe 'Get results' do
    it 'get result_sets by result_set_id' do
      result_set_name, message = Array.new(5).map { Array.new(30) { http.random_name }.join }
      run_id = JSON.parse(RunFunctions.create_new_run(http, {plan_name: http.random_name})[0].body)['run']['id']
      result_set_id = JSON.parse(ResultSetFunctions.create_new_result_set(http, {run_id: run_id,
                                                                                 result_set_name: result_set_name})[0].body)['result_set']['id']
      response = ResultFunctions.create_new_result(http,
                                                   { result_set_id: result_set_id,
                                                     message: message,
                                                     status: 'Passed' })
      results = JSON.parse(ResultFunctions.get_results(http, id: result_set_id).body)
      expect(results['errors'].empty?).to be_truthy
      expect(results['results'].count).to eq(1)
      expect(results['results'].first['id']).to eq(JSON.parse(response.body)['result']['id'])
    end
  end
end
