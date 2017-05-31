require_relative '../../tests/test_management'
http, run, result_set = nil
describe 'Result Set Smoke' do
  before :each do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
  end

  describe 'Create new result_sets' do
    it '1. Create product, plan, run and result set in one time' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map { 30.times.map {StaticData::ALPHABET.sample}.join}
      request = ResultSetFunctions.create_new_result_set(token: StaticData::TOKEN,
                                                         plan_name: plan_name,
                                                         run_name: run_name,
                                                         product_name: product_name,
                                                         result_set_name: result_set_name)
      responce = JSON.parse(http.request(request[0]).body)
      expect(responce['errors']).to be_empty
      expect(responce['result_set']['name']).to eq(result_set_name)
    end

    it '2. Create plan, run and result set in one time' do
      plan_name, run_name, result_set_name = Array.new(4).map { 30.times.map {StaticData::ALPHABET.sample}.join}
      product = ProductFunctions.create_new_product(StaticData::TOKEN)
      product_id = JSON.parse(http.request(product[0]).body)['product']['id']
      request = ResultSetFunctions.create_new_result_set(token: StaticData::TOKEN,
                                                         plan_name: plan_name,
                                                         run_name: run_name,
                                                         product_id: product_id,
                                                         result_set_name: result_set_name)
      responce = JSON.parse(http.request(request[0]).body)
      expect(responce['errors']).to be_empty
      expect(responce['result_set']['name']).to eq(result_set_name)
    end

    it '3. Create run and result set in one time' do
      run_name, result_set_name = Array.new(4).map { 30.times.map {StaticData::ALPHABET.sample}.join}
      product = ProductFunctions.create_new_product(StaticData::TOKEN)
      product_id = JSON.parse(http.request(product[0]).body)['product']['id']

      plan = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_id: product_id)
      plan_id = JSON.parse(http.request(plan[0]).body)['plan']['id']
      request = ResultSetFunctions.create_new_result_set(token: StaticData::TOKEN,
                                                         plan_id: plan_id,
                                                         run_name: run_name,
                                                         result_set_name: result_set_name)
      responce = JSON.parse(http.request(request[0]).body)
      expect(responce['errors']).to be_empty
      expect(responce['result_set']['name']).to eq(result_set_name)
    end

    it '4. Create result set in one time' do
      run_name, result_set_name = Array.new(4).map { 30.times.map {StaticData::ALPHABET.sample}.join}
      product = ProductFunctions.create_new_product(StaticData::TOKEN)
      product_id = JSON.parse(http.request(product[0]).body)['product']['id']
      plan = PlanFunctions.create_new_plan(token: StaticData::TOKEN, product_id: product_id)
      plan_id = JSON.parse(http.request(plan[0]).body)['plan']['id']
      run = RunFunctions.create_new_run(token: StaticData::TOKEN, plan_id: plan_id, run_name: run_name)
      run_id = JSON.parse(http.request(run[0]).body)['run']['id']
      request = ResultSetFunctions.create_new_result_set(token: StaticData::TOKEN,
                                                         run_id: run_id,
                                                         result_set_name: result_set_name)
      responce = JSON.parse(http.request(request[0]).body)
      expect(responce['errors']).to be_empty
      expect(responce['result_set']['name']).to eq(result_set_name)
    end
  end

  describe 'ResultSets show' do
    before :each do
      result_set_request = ResultSetFunctions.create_new_result_set(account.merge({"result_set_data[run_id]" => run['id'],
                                                                                   "result_set_data[status]" => 0}))
      result_set = JSON.parse(http.request(result_set_request[0]).body)['result_set']
    end

    it 'get result_sets by run_id' do
      result = ResultSetFunctions.get_result_sets(account.merge({"result_set_data[run_id]" => run['id']}))
      expect(result[result_set['id']]['id']).to eq(result_set['id'])
      expect(result[result_set['id']]['run_id']).to eq(run['id'])
    end

    it 'get result_sets by run_id with uncorrect user_data' do
      result = ResultSetFunctions.get_result_sets({"result_set_data[run_id]" => run['id']})
      expect(result['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'get result_sets by run_id with uncorrect result_set_data | run_id' do
      uncorrect_run_id = 30.times.map { StaticData::ALPHABET.sample }.join
      result = ResultSetFunctions.get_result_sets(account.merge({"result_set_data[run_id]" => uncorrect_run_id}))
      expect(result['errors']['run_id']).to eq([ErrorMessages::RUN_ID_WRONG])
    end

    it 'get result_sets by run_id with uncorrect result_set_data | run_id is empty' do
      result = ResultSetFunctions.get_result_sets(account.merge({"result_set_data[run_id]" => ''}))
      expect(result['errors']['run_id']).to eq([ErrorMessages::RUN_ID_CANT_BE_EMPTY])
    end
  end
end