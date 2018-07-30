require_relative '../../tests/test_management'
product_name, plan_name, run_name, new_case_name, result_set_name, http = nil
describe 'Cases Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
    product_name, plan_name, run_name, new_case_name, result_set_name = Array.new(5).map { http.random_name }
  end

  describe 'Create case' do
    it 'check creating new case after result_set created' do
      result_set = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                           run_name: run_name,
                                                                           product_name: product_name,
                                                                           name: result_set_name)[0]
      case_pack = CaseFunctions.get_cases(http, id: result_set.run.plan.product.suite.id)
      expect(case_pack.cases.size).to eq(1)
      expect(case_pack.cases.first.name).to eq(result_set_name)
    end
  end

  describe 'Get cases by run_id' do
    it 'get cases by run_id' do
      result_set = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                                      run_name: run_name,
                                                                                      product_name: product_name,
                                                                                      name: result_set_name)[0]

      case_pack = CaseFunctions.get_cases(http, product_id: result_set.run.plan.product.id,
                                                          run_id: result_set.run.id)
      expect(case_pack.cases.size).to eq(1)
      expect(case_pack.cases.first.name).to eq(result_set_name)
    end
  end

  describe 'Case edit by case id' do
    it 'Change case name' do
      result_set = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                          run_name: run_name,
                                                                          product_name: product_name,
                                                                          result_set_name: result_set_name)[0]
      cases = CaseFunctions.get_cases(http, id: result_set.run.plan.product.suite.id).cases
      case_id_for_edit = cases.first.id
      responce_update = CaseFunctions.update_case(http, id: case_id_for_edit, name: new_case_name)
      case_pack = CaseFunctions.get_cases(http, id: result_set.run.plan.product.suite.id)
      expect(responce_update.responce.code).to eq('200')
      expect(case_pack.cases.first.name).to eq(new_case_name)
    end

    it 'Change case name check result_sets rename' do
      result_set = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                          run_name: run_name,
                                                                          product_name: product_name,
                                                                          result_set_name: result_set_name)[0]
      case_pack = CaseFunctions.get_cases(http, id: result_set.run.plan.product.suite.id)
      case_new = CaseFunctions.update_case(http, id: case_pack.cases.first.id, name: new_case_name)
      case_pack = CaseFunctions.get_cases(http, id: result_set.run.plan.product.suite.id)
      result_set = ResultSetFunctions.get_result_set(http, id: result_set.id)
      expect(result_set.name).to eq(new_case_name)
    end

    it 'Change case name check result_sets from other runs not rename' do
      product_name, plan_name, run_name, run_name_second, new_case_name, result_set_name = Array.new(6).map { http.random_name }
      result_set_first = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                                run_name: run_name,
                                                                                product_name: product_name,
                                                                                result_set_name: result_set_name)[0]
      result_set_second = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                                 run_name: run_name_second,
                                                                                 product_name: product_name,
                                                                                 name: result_set_name)[0]
      case_pack = CaseFunctions.get_cases(http, id: result_set_first.run.plan.product.suite.id)
      CaseFunctions.update_case(http, id: case_pack.cases.first.id, name: new_case_name)
      new_case_first_pack = CaseFunctions.get_cases(http, id: result_set_first.run.plan.product.suite.id)
      new_case_second_pack= CaseFunctions.get_cases(http, id: result_set_second.run.plan.product.suite.id)
      result_set = ResultSetFunctions.get_result_set(http, id: result_set_first.id)
      expect(result_set.name).to eq(new_case_name)
      expect(new_case_first_pack.cases.first.name).to eq(new_case_name)
      expect(new_case_second_pack.cases.first.name).to eq(result_set_name)
    end

    it 'Case edit by result_set' do
      product_name, plan_name, run_name, new_case_name, result_set_name = Array.new(5).map { http.random_name }
      result_set = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                          run_name: run_name,
                                                                          product_name: product_name,
                                                                          result_set_name: result_set_name)[0]
      case_pack = CaseFunctions.get_cases(http, id: result_set.run.plan.product.suite.id)
      new_case = CaseFunctions.update_case(http, result_set_id: result_set.id, name: new_case_name)
      case_pack_new = CaseFunctions.get_cases(http, id: result_set.run.plan.product.suite.id)
      expect(new_case.responce.code).to eq('200')
      expect(case_pack_new.cases.first.name).to eq(new_case_name)
    end
  end

  describe 'Delete case' do
    it 'Delete case by id' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map { http.random_name }
      result_set = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                                      run_name: run_name,
                                                                                      product_name: product_name,
                                                                                      result_set_name: result_set_name)[0]
      case_pack = CaseFunctions.get_cases(http, id: result_set.run.plan.product.suite.id)
      CaseFunctions.delete_case(http, id: case_pack.cases.first.id)
      new_case_pack = CaseFunctions.get_cases(http, id: result_set.run.plan.product.suite.id)
      expect(new_case_pack.cases.size).to eq(0)
    end

    it 'result set will be delete if case delete' do
      result_set = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                                     run_name: run_name,
                                                                                     product_name: product_name)[0]
      case_pack = CaseFunctions.get_cases(http, id: result_set.run.plan.product.suite.id)
      CaseFunctions.delete_case(http, id: case_pack.cases.first.id)
      cases_after_deletind = CaseFunctions.get_cases(http, id: result_set.run.plan.product.suite.id)
      result_set_pack = ResultSetFunctions.get_result_sets(http, id: result_set.run.id)[0]
      expect(cases_after_deletind.cases).to be_empty
      expect(result_set_pack.result_sets).to be_empty
    end

    it 'not delete case if case with this name is exist in other suite' do
      product_name, plan_name, run_name, result_set_name, run_name2 = Array.new(5).map { http.random_name }
      first_result_set = ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                                  run_name: run_name,
                                                                                  product_name: product_name,
                                                                                  result_set_name: result_set_name)[0]
      second_result_set = ResultSetFunctions.create_new_result_set(http, plan_id: first_result_set.run.plan.id,
                                                                                   run_name: run_name2,
                                                                                   result_set_name: result_set_name)[0]
      case_pack = CaseFunctions.get_cases(http, id: first_result_set.run.plan.product.suite.id)
      CaseFunctions.delete_case(http, id: case_pack.cases.first.id)
      responce_first = ResultSetFunctions.get_result_set(http, id: first_result_set.id)
      responce_second = ResultSetFunctions.get_result_set(http, id: second_result_set.id)
      cases_after_deleting = CaseFunctions.get_cases(http, id: first_result_set.run.plan.product.suite.id)
      expect(responce_first.is_null).to be_truthy
      expect(responce_second.is_null).to be_falsey
      expect(cases_after_deleting.cases.empty?).to be_truthy
    end
  end
end
