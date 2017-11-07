require_relative '../../tests/test_management'
http = nil
describe 'Result Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Get history from case id' do
    it '1. Check creating new result with all other elements' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map {http.random_name}
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                     run_name: run_name,
                                                                     product_name: product_name,
                                                                     result_set_name: result_set_name)[0].body)
      responce
      responce = JSON.parse(CaseFunctions.get_cases(http, id: responce['other_data']['suite_id']).body)

      response = ResultFunctions.create_new_result(http,
                                                   result_set_id: result_set_id,
                                                   message: message,
                                                   status: 'Passed')


      responce = JSON.parse(HistoryFunctions.case_history(http, responce['cases'].first['id']))
      expect(responce['cases'].size).to eq(1)
      expect(responce['cases'].first['name']).to eq(result_set_name)
    end
  end
end
