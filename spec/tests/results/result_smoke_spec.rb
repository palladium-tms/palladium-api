require_relative '../../tests/test_management'
http, run, result_set, status = nil
describe 'Result Smoke' do
  before :each do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
  end

  describe 'Create new result' do
    it '1. Check creating new result with all other elements' do
      product_name, plan_name, run_name, result_set_name, message = Array.new(5).map { 30.times.map {StaticData::ALPHABET.sample}.join}
      request = ResultFunctions.create_new_result(token: StaticData::TOKEN,
                                                         plan_name: plan_name,
                                                         run_name: run_name,
                                                         product_name: product_name,
                                                         result_set_name: result_set_name,
                                                         message: message)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
    end

    it '2. Check creating new result | only product has created before' do
      product = ProductFunctions.create_new_product(StaticData::TOKEN)
      product_id = JSON.parse(http.request(product[0]).body)['product']['id']

      plan_name, run_name, result_set_name, message = Array.new(5).map { 30.times.map {StaticData::ALPHABET.sample}.join}
      request = ResultFunctions.create_new_result(token: StaticData::TOKEN,
                                                  plan_name: plan_name,
                                                  run_name: run_name,
                                                  product_id: product_id,
                                                  result_set_name: result_set_name,
                                                  message: message)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
    end

    it '3. Check creating new result | only product and plan has created before' do
      product = ProductFunctions.create_new_product(StaticData::TOKEN)
      product_id = JSON.parse(http.request(product[0]).body)['product']['id']

      plan = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_id: product_id)
      plan_id = JSON.parse(http.request(plan[0]).body)['plan']['id']

      run_name, result_set_name, message = Array.new(5).map { 30.times.map {StaticData::ALPHABET.sample}.join}
      request = ResultFunctions.create_new_result(token: StaticData::TOKEN,
                                                  plan_id: plan_id,
                                                  run_name: run_name,
                                                  result_set_name: result_set_name,
                                                  message: message)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
    end


    it '4. Check creating new result | only product, plan and run has created before' do
      run_name, result_set_name, message = Array.new(5).map { 30.times.map {StaticData::ALPHABET.sample}.join}
      product = ProductFunctions.create_new_product(StaticData::TOKEN)
      product_id = JSON.parse(http.request(product[0]).body)['product']['id']

      plan = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_id: product_id)
      plan_id = JSON.parse(http.request(plan[0]).body)['plan']['id']

      run = RunFunctions.create_new_run(token: StaticData::TOKEN, plan_id: plan_id, run_name: run_name)
      run_id = JSON.parse(http.request(run[0]).body)['run']['id']

      request = ResultFunctions.create_new_result(token: StaticData::TOKEN,
                                                  plan_id: plan_id,
                                                  run_id: run_id,
                                                  result_set_name: result_set_name,
                                                  message: message)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
    end

    it '5. Check creating new result | only product, plan, run and result set has created before' do
      run_name, result_set_name, message = Array.new(5).map { 30.times.map {StaticData::ALPHABET.sample}.join}
      product = ProductFunctions.create_new_product(StaticData::TOKEN)
      product_id = JSON.parse(http.request(product[0]).body)['product']['id']

      plan = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_id: product_id)
      plan_id = JSON.parse(http.request(plan[0]).body)['plan']['id']

      run = RunFunctions.create_new_run(token: StaticData::TOKEN, plan_id: plan_id, run_name: run_name)
      run_id = JSON.parse(http.request(run[0]).body)['run']['id']

      request = ResultSetFunctions.create_new_result_set(token: StaticData::TOKEN,
                                                         run_id: run_id,
                                                         result_set_name: result_set_name)
      result_set_id = JSON.parse(http.request(request[0]).body)['result_set']['id']

      request = ResultFunctions.create_new_result(token: StaticData::TOKEN,
                                                  plan_id: plan_id,
                                                  run_id: run_id,
                                                  result_set_id: result_set_id,
                                                  message: message)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['result']['id'].nil?).to be_falsey
    end
  end
end