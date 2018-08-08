require_relative '../../tests/test_management'
http = nil
describe 'Result Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end
  # Fixme: add more checks for history
  describe 'Get history from case id' do
    it '1. Check creating new result with all other elements' do
      product_name, plan_name, result_set_name, run_name = Array.new(5).map { http.random_name }
      run_first = RunFunctions.create_new_run(http, plan_name: plan_name,
                                                    product_name: product_name, name: run_name)[0]


      ResultFunctions.create_new_result(http, run_id: run_first.id,
                                              result_set_name: result_set_name,
                                              message: 'MessageFor_1',
                                              status: 'Passed')


      2.times do |i|
        ResultFunctions.create_new_result(http, run_id: run_first.id,
                                                result_set_name: result_set_name,
                                                message: 'MessageFor_' + i.to_s,
                                                status: 'Passed')
      end
      run_second = RunFunctions.create_new_run(http, plan_name: plan_name + '2',
                                                     product_name: product_name, name: run_name)[0]
      second_result = ResultFunctions.create_new_result(http, run_id: run_first.id,
                                                              result_set_name: result_set_name,
                                                              message: 'MessageFor_1',
                                                              status: 'Passed')[0]
      2.times do |i|
        ResultFunctions.create_new_result(http, run_id: second_result.id,
                                                result_set_name: result_set_name,
                                                message: 'MessageFor_' + i.to_s,
                                                status: 'Passed')
      end
      case_pack = CaseFunctions.get_cases(http, id: run_first.plan.product.suite.id)

      history_pack = HistoryFunctions.case_history(http, case_pack.cases.first.id)
      expect(history_pack.histories.size).to eq(2)
      expect(history_pack.histories[0].plan_id).to eq(run_first.plan.id)
      expect(history_pack.histories[0].run_id).to eq(run_first.id)
      expect(history_pack.histories[1].plan_id).to eq(run_second.plan.id)
      expect(history_pack.histories[1].run_id).to eq(run_second.id)
    end

    it 'Get history only by 30 plans' do
      product_name, plan_name, result_set_name, run_name = Array.new(5).map {http.random_name}
      run = RunFunctions.create_new_run(http, plan_name: plan_name,
                                        product_name: product_name, name: run_name)[0]
      results = []
      35.times do |i|
        sleep 1
        results << ResultFunctions.create_new_result(http, product_name: product_name,
                                                     plan_name: plan_name + i.to_s,
                                                     run_name: run.name,
                                                     result_set_name: result_set_name,
                                                     message: 'MessageFor_' + i.to_s,
                                                     status: 'Passed')[0].result_set.run.plan.id
      end
      case_pack = CaseFunctions.get_cases(http, id: run.plan.product.suite.id)

      history_pack = HistoryFunctions.case_history(http, case_pack.cases.first.id)
      expect(history_pack.histories.size).to eq(30)
      expect(history_pack.get_youngest_by_plan).to eq(results.last)
      expect(history_pack.get_oldest_by_plan).to eq(results[5])
    end
  end
end
