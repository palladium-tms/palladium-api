require_relative '../../tests/test_management'
http = nil
describe 'Result Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Create new result' do
    it '1. Check creating new result with all other elements' do
      product_name, plan_name, run_name, result_set_name, message = Array.new(5).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      response = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                         run_name: run_name,
                                                         product_name: product_name,
                                                         result_set_name: result_set_name,
                                                         message: message,
                                                         status: 'Passed')
      expect(response.code).to eq('200')
      body = JSON.parse(response.body)
      expect(body.keys.size).to eq(6)
      expect(body['result_sets'][0]['name']).to eq(result_set_name)
      expect(body['product']['name']).to eq(product_name)
      expect(body['plan']['name']).to eq(plan_name)
      expect(body['run']['name']).to eq(run_name)
      expect(body['result']['message']).to eq(message)
      expect(body['status']['name']).to eq('Passed')
    end

    it '2. Check creating new result | only product has created before' do
      product_id = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']['id']
      plan_name, run_name, result_set_name, message = Array.new(5).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      response = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                         run_name: run_name,
                                                         product_id: product_id,
                                                         result_set_name: result_set_name,
                                                         message: message,
                                                         status: 'Passed')
      expect(response.code).to eq('200')
      body = JSON.parse(response.body)
      expect(body.keys.size).to eq(6)
      expect(body['result_sets'][0]['name']).to eq(result_set_name)
      expect(body['product']['id']).to eq(product_id)
      expect(body['plan']['name']).to eq(plan_name)
      expect(body['run']['name']).to eq(run_name)
      expect(body['result']['message']).to eq(message)
      expect(body['status']['name']).to eq('Passed')
    end

    it '3. Check creating new result | only product and plan has created before' do
      product_id = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']['id']
      plan_id = JSON.parse(PlanFunctions.create_new_plan(http, product_id: product_id)[0].body)['plan']['id']
      run_name, result_set_name, message = Array.new(5).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      response = ResultFunctions.create_new_result(http,
                                                   plan_id: plan_id,
                                                   run_name: run_name,
                                                   result_set_name: result_set_name,
                                                   message: message,
                                                   status: 'Passed')
      expect(response.code).to eq('200')
      body = JSON.parse(response.body)
      expect(body.keys.size).to eq(5)
      expect(body['result_sets'][0]['name']).to eq(result_set_name)
      expect(body['plan']['id']).to eq(plan_id)
      expect(body['run']['name']).to eq(run_name)
      expect(body['result']['message']).to eq(message)
      expect(body['status']['name']).to eq('Passed')
    end

    it '4. Check creating new result | only product, plan and run has created before' do
      result_set_name, message = Array.new(5).map { Array.new(30) { http.random_name }.join }
      run_id = JSON.parse(RunFunctions.create_new_run(http, plan_name: http.random_name,
                                                            product_name: http.random_name)[0].body)['run']['id']
      response = ResultFunctions.create_new_result(http, run_id: run_id,
                                                         result_set_name: result_set_name,
                                                         message: message,
                                                         status: 'Passed')
      expect(response.code).to eq('200')
      body = JSON.parse(response.body)
      expect(body.keys.size).to eq(4)
      expect(body['result_sets'][0]['name']).to eq(result_set_name)
      expect(body['run']['id']).to eq(run_id)
      expect(body['result']['message']).to eq(message)
      expect(body['status']['name']).to eq('Passed')
    end

    it '5. Check creating new result | only product, plan, run and result set has created before' do
      result_set_name, message = Array.new(2).map { http.random_name }
      run_id = JSON.parse(RunFunctions.create_new_run(http, plan_name: http.random_name,
                                                            product_name: http.random_name)[0].body)['run']['id']
      result_set_id = ResultSetFunctions.create_new_result_set_and_parse(http,
                                                                         run_id: run_id,
                                                                         name: result_set_name)[0]['result_sets'][0]['id']
      response = ResultFunctions.create_new_result(http,
                                                   result_set_id: result_set_id,
                                                   message: message,
                                                   status: 'Passed')
      expect(response.code).to eq('200')
      body = JSON.parse(response.body)
      expect(body.keys.size).to eq(3)
      expect(body['result_sets'][0]['name']).to eq(result_set_name)
      expect(body['result']['message']).to eq(message)
      expect(body['status']['name']).to eq('Passed')
    end

    # You can send array of result_sets for create this result for every this result_sets
    it '6. Create result from multiple creator' do
      result_set_name, message, plan_name, product_name = Array.new(4).map { http.random_name }
      run_id = JSON.parse(RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0].body)['run']['id']
      result_set_array = (1..3).to_a.map do |iterator|
        JSON.parse(ResultSetFunctions.create_new_result_set(http,
                                                            run_id: run_id,
                                                            result_set_name: result_set_name + iterator.to_s)[0].body)['result_sets'][0]['id']
      end

      response = ResultFunctions.create_new_result(http,
                                                   result_set_id: result_set_array,
                                                   message: message,
                                                   status: 'Passed')
      expect(response.code).to eq('200')
      body = JSON.parse(response.body)
      expect(body.keys.size).to eq(3)
      expect(body['result_sets'][0]['name']).to eq(result_set_name)
      expect(body['result']['message']).to eq(message)
      expect(body['status']['name']).to eq('Passed')
    end

    it '7. Create result and result_sets from name array and run id' do
      result_set_name1, result_set_name2, result_set_name3, message = Array.new(4).map { http.random_name }
      run_id = JSON.parse(RunFunctions.create_new_run(http, plan_name: http.random_name,
                                                            product_name: http.random_name)[0].body)['run']['id']
      response = ResultFunctions.create_new_result(http, run_id: run_id,
                                                         result_set_name: [result_set_name1,
                                                                           result_set_name2,
                                                                           result_set_name3],
                                                         message: message,
                                                         status: 'Passed')
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
    end

    it '8. Create result by case and plan_id' do
      product_id = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']['id']
      plan_name, run_name, result_set_name, message, new_plan = Array.new(6).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      response = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                   run_name: run_name,
                                                   product_id: product_id,
                                                   result_set_name: result_set_name,
                                                   message: message,
                                                   status: 'Passed')
      plan_id = JSON.parse(PlanFunctions.create_new_plan(http, {plan_name: new_plan, product_id: product_id})[0].body)['plan']['id']
      a = CaseFunctions.get_cases(http, {id: JSON.parse(response.body)['other_data']['suite_id']}).body

      case_id = JSON.parse(CaseFunctions.get_cases(http, {id: JSON.parse(response.body)['other_data']['suite_id']}).body)['cases'][0]['id']

      result_responce = ResultFunctions.create_new_result(http, plan_id: plan_id,
                                                   case_id: case_id,
                                                   message: message,
                                                   status: 'Passed')
      expect(result_responce.code).to eq('200')
      expect(JSON.parse(result_responce.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(result_responce.body)['result']['id'].nil?).to be_falsey
    end

    it '9. Check creating new result with + in name' do
      result_set_name, message = Array.new(5).map { Array.new(30) { http.random_name }.join }
      run_id = JSON.parse(RunFunctions.create_new_run(http, plan_name: http.random_name,
                                                      product_name: http.random_name)[0].body)['run']['id']
      result_set_id = ResultSetFunctions.create_new_result_set_and_parse(http,
                                                                         run_id: run_id,
                                                                         result_set_name: '123123 + 123123')[0]['result_set'][0]['id']
      response = ResultFunctions.create_new_result(http,
                                                   result_set_id: result_set_id,
                                                   message: message,
                                                   status: 'Passed')
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['other_data']['result_set_id']).to eq([result_set_id])
    end
  end

  describe 'Get results' do
    it 'get results by result_set_id' do
      result_set_name, message, product_name, plan_name = Array.new(5).map { http.random_name }
      run_id = JSON.parse(RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0].body)['run']['id']
      result_set_id = ResultSetFunctions.create_new_result_set_and_parse(http, run_id: run_id,
                                                                               result_set_name: result_set_name)[0]['result_set'][0]['id']
      response = ResultFunctions.create_new_result(http,
                                                   result_set_id: result_set_id,
                                                   message: message,
                                                   status: 'Passed')
      results = JSON.parse(ResultFunctions.get_results(http, id: result_set_id).body)
      expect(results['errors'].empty?).to be_truthy
      expect(results['results'].count).to eq(1)
      expect(results['results'].first['id']).to eq(JSON.parse(response.body)['result']['id'])
    end
  end

  describe 'Get result' do
    it 'get result for one result' do
      result_set_name, message, product_name, plan_name = Array.new(5).map { http.random_name }
      run_id = JSON.parse(RunFunctions.create_new_run(http, plan_name: plan_name, product_name: product_name)[0].body)['run']['id']
      result_set_id = ResultSetFunctions.create_new_result_set_and_parse(http, run_id: run_id,
                                                                         result_set_name: result_set_name)[0]['result_set'][0]['id']
      response = ResultFunctions.create_new_result(http,
                                                   result_set_id: result_set_id,
                                                   message: message,
                                                   status: 'Passed')
      results = JSON.parse(ResultFunctions.get_results(http, id: result_set_id).body)
      result = JSON.parse(ResultFunctions.get_result(http, results['results'][0]['id']).body)
      expect(result['result']['id']).to eq(results['results'][0]['id'])
      expect(result['result']['message']).to eq(message)
    end
  end
end
