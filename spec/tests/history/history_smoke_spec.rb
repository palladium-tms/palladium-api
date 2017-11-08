require_relative '../../tests/test_management'
http = nil
describe 'Result Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Get history from case id' do
    it '1. Check creating new result with all other elements' do
      product_name, plan_name, message, result_set_name, run_name = Array.new(5).map {http.random_name}
      response_first, run_name = RunFunctions.create_new_run_and_parse(http, plan_name: plan_name,
                                                                 product_name: product_name, run_name: run_name)
      first_result_set = ResultFunctions.create_new_result_and_parse(http, run_id: response_first['run']['id'],
                                        result_set_name: result_set_name,
                                        message: 'MessageFor_1',
                                        status: 'Passed')
      2.times do |i|
        ResultFunctions.create_new_result(http, run_id: response_first['run']['id'],
                                          result_set_name: result_set_name,
                                          message: 'MessageFor_' + i.to_s,
                                          status: 'Passed')
      end
      response, run_name = RunFunctions.create_new_run_and_parse(http, plan_name: plan_name + '2',
                                                                 product_name: product_name, run_name: run_name)
      second_result_set = ResultFunctions.create_new_result_and_parse(http, run_id: response_first['run']['id'],
                                                           result_set_name: result_set_name,
                                                           message: 'MessageFor_1',
                                                           status: 'Passed')
      2.times do |i|
        ResultFunctions.create_new_result(http, run_id: response['run']['id'],
                                          result_set_name: result_set_name,
                                          message: 'MessageFor_' + i.to_s,
                                          status: 'Passed')
      end
      responce = JSON.parse(CaseFunctions.get_cases(http, id: response_first['other_data']['suite_id']).body)

      responce = JSON.parse(HistoryFunctions.case_history(http, responce['cases'].first['id']).body)
      expect(responce['history_data'].size).to eq(2)
      expect(responce['history_data'].keys).to eq(first_result_set['other_data']['result_set_id'] + second_result_set['other_data']['result_set_id'])
      expect(responce['cases'].first['name']).to eq(result_set_name)
    end
  end
end
