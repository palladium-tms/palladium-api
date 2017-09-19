require_relative '../../tests/test_management'
http = nil
describe 'Cases Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Create case' do
    it 'check creating new case after result_set created' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map {http.random_name}
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                     run_name: run_name,
                                                                     product_name: product_name,
                                                                     result_set_name: result_set_name)[0].body)
      responce = JSON.parse(CaseFunctions.get_cases(http, id: responce['other_data']['suite_id']).body)
      expect(responce['cases'].size).to eq(1)
      expect(responce['cases'].first['name']).to eq(result_set_name)
    end
  end

  describe 'Delete case' do
    it 'Delete case by id' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map {http.random_name}
      responce_result_set = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                                run_name: run_name,
                                                                                product_name: product_name,
                                                                                result_set_name: result_set_name)[0].body)
      id = JSON.parse(CaseFunctions.get_cases(http, id: responce_result_set['other_data']['suite_id']).body)['cases'].first['id']
      CaseFunctions.delete_case(http, id: id)
      responce = JSON.parse(CaseFunctions.get_cases(http, id: responce_result_set['other_data']['suite_id']).body)
      expect(responce['cases'].size).to eq(0)
    end

    it 'delete case if suite is deleted' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map {http.random_name}
      responce_result_set = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                                run_name: run_name,
                                                                                product_name: product_name,
                                                                                result_set_name: result_set_name)[0].body)
      SuiteFunctions.delete_suite(http, id: responce_result_set['other_data']['suite_id']) # deleting suite
      responce = JSON.parse(CaseFunctions.get_cases(http, id: responce_result_set['other_data']['suite_id']).body)
      expect(responce['cases']).to be_empty
    end
  end
end
