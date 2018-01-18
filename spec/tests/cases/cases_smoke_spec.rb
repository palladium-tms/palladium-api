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
                                                                     name: result_set_name)[0].body)
      responce = JSON.parse(CaseFunctions.get_cases(http, id: responce['other_data']['suite_id']).body)
      expect(responce['cases'].size).to eq(1)
      expect(responce['cases'].first['name']).to eq(result_set_name)
    end
  end

  describe 'Get cases by run_id' do
    it 'get cases by run_id' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map {http.random_name}
      result_set_responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                                run_name: run_name,
                                                                                product_name: product_name,
                                                                                name: result_set_name)[0].body)

      responce = JSON.parse(CaseFunctions.get_cases(http, product_id: result_set_responce['other_data']['product_id'],
                                                    run_id: result_set_responce['other_data']['run_id']).body)
      expect(responce['cases'].size).to eq(1)
      expect(responce['cases'].first['name']).to eq(result_set_name)
    end
  end

  describe 'Case edit by case id' do
    it 'Change case name' do
      product_name, plan_name, run_name, new_case_name, result_set_name = Array.new(5).map {http.random_name}
      responce = ResultSetFunctions.create_new_result_set_and_parse(http, plan_name: plan_name,
                                                         run_name: run_name,
                                                         product_name: product_name,
                                                         result_set_name: result_set_name)[0]
      cases = JSON.parse(CaseFunctions.get_cases(http, id: responce['other_data']['suite_id']).body)['cases']
      case_id_for_edit = cases.first['id']
      responce_update = CaseFunctions.update_case(http, id: case_id_for_edit, name: new_case_name)
      responce_new = JSON.parse(CaseFunctions.get_cases(http, id: responce['other_data']['suite_id']).body)
      expect(responce_update.code).to eq('200')
      expect(responce_new['cases'].first['name']).to eq(new_case_name)
    end

    it 'Change case name check result_sets rename' do
      product_name, plan_name, run_name, new_case_name, result_set_name = Array.new(5).map {http.random_name}
      responce = ResultSetFunctions.create_new_result_set_and_parse(http, plan_name: plan_name,
                                                                    run_name: run_name,
                                                                    product_name: product_name,
                                                                    result_set_name: result_set_name)[0]
      cases = JSON.parse(CaseFunctions.get_cases(http, id: responce['other_data']['suite_id']).body)['cases']
      case_id_for_edit = cases.first['id']
      responce_update = CaseFunctions.update_case(http, id: case_id_for_edit, name: new_case_name)
      responce_new = JSON.parse(CaseFunctions.get_cases(http, id: responce['other_data']['suite_id']).body)
      result_set = ResultSetFunctions.get_result_set(http, id:  responce['result_set'][0]['id'])
      result_set = JSON.parse(ResultSetFunctions.get_result_set(http, id:  responce['result_set'][0]['id']).body)
      expect(result_set['result_set']['name']).to eq(new_case_name)
    end

    it 'Change case name check result_sets from other runs not rename' do
      product_name, plan_name, run_name, run_name_second, new_case_name, result_set_name = Array.new(6).map {http.random_name}
      responce_first = ResultSetFunctions.create_new_result_set_and_parse(http, plan_name: plan_name,
                                                                    run_name: run_name,
                                                                    product_name: product_name,
                                                                    result_set_name: result_set_name)[0]
      responce_second = ResultSetFunctions.create_new_result_set_and_parse(http, plan_name: plan_name,
                                                                          run_name: run_name_second,
                                                                          product_name: product_name,
                                                                          name: result_set_name)[0]
      cases = JSON.parse(CaseFunctions.get_cases(http, id: responce_first['other_data']['suite_id']).body)['cases']
      case_id_for_edit = cases.first['id']
      responce_update = CaseFunctions.update_case(http, id: case_id_for_edit, name: new_case_name)
      responce_new = JSON.parse(CaseFunctions.get_cases(http, id: responce_first['other_data']['suite_id']).body)
      responce_second = JSON.parse(CaseFunctions.get_cases(http, id: responce_second['other_data']['suite_id']).body)
      result_set = JSON.parse(ResultSetFunctions.get_result_set(http, id:  responce_first['result_set'][0]['id']).body)
      expect(result_set['result_set']['name']).to eq(new_case_name)
      expect(responce_new['cases'].first['name']).to eq(new_case_name)
      expect(responce_second['cases'].first['name']).to eq(result_set_name)
    end

    it 'Case edit by result_set' do
      product_name, plan_name, run_name, new_case_name, result_set_name = Array.new(5).map {http.random_name}
      responce = ResultSetFunctions.create_new_result_set_and_parse(http, plan_name: plan_name,
                                                                    run_name: run_name,
                                                                    product_name: product_name,
                                                                    result_set_name: result_set_name)[0]
      cases = JSON.parse(CaseFunctions.get_cases(http, id: responce['other_data']['suite_id']).body)['cases']
      case_id_for_edit = cases.first['id']
      responce_update = CaseFunctions.update_case(http, result_set_id: responce['result_set'][0]['id'], name: new_case_name)
      responce_new = JSON.parse(CaseFunctions.get_cases(http, id: responce['other_data']['suite_id']).body)
      expect(responce_update.code).to eq('200')
      expect(responce_new['cases'].first['name']).to eq(new_case_name)
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

    it 'delete all result sets if case is deleted' do
      # if you delete case - all result sets from this name, from this product
      # and with suite name == runs
      product_name, plan_name, run_name, result_set_name = Array.new(4).map {http.random_name}
      responce_result_set = ResultSetFunctions.create_new_result_set_and_parse(http, plan_name: plan_name,
                                                                               run_name: run_name,
                                                                               product_name: product_name,
                                                                               result_set_name: result_set_name)[0]
      id = JSON.parse(CaseFunctions.get_cases(http, id: responce_result_set['other_data']['suite_id']).body)['cases'].first['id']
      CaseFunctions.delete_case(http, id: id)
      cases_after_deletind = JSON.parse(CaseFunctions.get_cases(http, id: responce_result_set['other_data']['suite_id']).body)['cases']
      result_sets_after_deleting = JSON.parse(ResultSetFunctions.get_result_sets(http, id: responce_result_set['other_data']['run_id']).body)['result_sets']
      responce = JSON.parse(ResultSetFunctions.get_result_sets(http, id: responce_result_set['other_data']['run_id']).body)
      responce = JSON.parse(CaseFunctions.get_cases(http, id: responce_result_set['other_data']['suite_id']).body)
      expect(cases_after_deletind).to be_empty
      expect(result_sets_after_deleting).to be_empty
    end

    it 'delete case if case with this name is exist in other suite' do
      product_name, plan_name, run_name, result_set_name, run_name2 = Array.new(5).map {http.random_name}
      first_result_set = ResultSetFunctions.create_new_result_set_and_parse(http, plan_name: plan_name,
                                                                               run_name: run_name,
                                                                               product_name: product_name,
                                                                               result_set_name: result_set_name)[0]
      second_result_set = ResultSetFunctions.create_new_result_set_and_parse(http, plan_id: first_result_set['other_data']['plan_id'],
                                                                             run_name: run_name2,
                                                                             result_set_name: result_set_name)[0]
      id = JSON.parse(CaseFunctions.get_cases(http, id: first_result_set['other_data']['suite_id']).body)['cases'].first['id']
       ResultFunctions.create_new_result(http,result_set_id: first_result_set['result_set'][0]['id'],
                                                   message: 'message',
                                                   status: 'Passed')
       ResultFunctions.create_new_result(http,result_set_id: second_result_set['result_set'][0]['id'],
                                                   message: 'message',
                                                   status: 'Passed')
      CaseFunctions.delete_case(http, id: id)
      responce_first = ResultSetFunctions.get_result_set(http, id: first_result_set['result_set'][0]['id'])
      responce_second = ResultSetFunctions.get_result_set(http, id: second_result_set['result_set'][0]['id'])
      expect(responce_first.code).to eq('500')
      expect(responce_second.code).to eq('200')
    end
  end
end
