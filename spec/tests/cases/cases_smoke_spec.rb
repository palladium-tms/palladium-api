require_relative '../../tests/test_management'
describe 'Cases Smoke' do
  before do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'Create case' do
    it 'check creating new case after result_set created' do
      result_set = @user.create_new_result_set(plan_name: rand_plan_name,
                                               run_name: rand_run_name,
                                               product_name: rand_product_name,
                                               name: rand_result_set_name)
      case_pack = @user.get_cases_from_plan(plan_id: result_set.run.plan.id, suite_id: result_set.run.plan.product.suite.id)
      expect(case_pack.cases.size).to eq(1)
      expect(case_pack.cases.first.name).to eq(result_set.name)
    end
  end

  describe 'Get cases by run_id' do
    it 'get cases by run_id' do
      result_set = @user.create_new_result_set(plan_name: rand_plan_name,
                                               run_name: rand_run_name,
                                               product_name: rand_product_name,
                                               name: rand_result_set_name)

      case_pack = @user.get_cases_from_plan(plan_id: result_set.run.plan.id,
                                            run_id: result_set.run.id)
      expect(case_pack.cases.size).to eq(1)
      expect(case_pack.cases.first.name).to eq(result_set.name)
    end
  end

  describe 'Case edit by case id' do
    before do
      @params = { plan_name: rand_plan_name,
                  run_name: rand_run_name,
                  product_name: rand_product_name,
                  name: rand_result_set_name }
    end

    it 'Change case name' do
      result_set = @user.create_new_result_set(plan_name: rand_plan_name,
                                               run_name: rand_run_name,
                                               product_name: rand_product_name,
                                               name: rand_result_set_name)
      cases = @user.get_cases(id: result_set.run.plan.product.suite.id).cases
      new_case_name = rand_result_set_name
      response_update = @user.update_case(id: cases.first.id, name: new_case_name)
      case_pack = @user.get_cases(id: result_set.run.plan.product.suite.id)
      expect(response_update.response.code).to eq('200')
      expect(case_pack.cases.first.name).to eq(new_case_name)
    end

    it 'Change case name check result_sets rename' do
      result_set = @user.create_new_result_set(plan_name: rand_plan_name,
                                               run_name: rand_run_name,
                                               product_name: rand_product_name,
                                               name: rand_result_set_name)
      new_case_name = rand_result_set_name
      case_pack = @user.get_cases(id: result_set.run.plan.product.suite.id)
      @user.update_case(id: case_pack.cases.first.id, name: new_case_name)
      result_set = @user.get_result_set(id: result_set.id)
      expect(result_set.name).to eq(new_case_name)
    end

    it 'Change case name check result_sets from other runs not rename' do
      result_set_first = @user.create_new_result_set(@params)
      @params[:run_name] = rand_run_name
      result_set_second = @user.create_new_result_set(@params)

      case_pack = @user.get_cases(id: result_set_first.run.plan.product.suite.id)
      new_case_name = rand_result_set_name
      @user.update_case(id: case_pack.cases.first.id, name: new_case_name)

      new_case_first_pack = @user.get_cases(id: result_set_first.run.plan.product.suite.id)
      new_case_second_pack = @user.get_cases(id: result_set_second.run.plan.product.suite.id)
      result_set = @user.get_result_set(id: result_set_first.id)
      expect(result_set.name).to eq(new_case_name)
      expect(new_case_first_pack.cases.first.name).to eq(new_case_name)
      expect(new_case_second_pack.cases.first.name).to eq(result_set_second.name)
    end

    it 'Case edit by result_set' do
      result_set = @user.create_new_result_set(@params)
      new_case_name = rand_result_set_name
      new_case = @user.update_case(result_set_id: result_set.id, name: new_case_name)
      case_pack_new = @user.get_cases(id: result_set.run.plan.product.suite.id)
      expect(new_case.response.code).to eq('200')
      expect(case_pack_new.cases.first.name).to eq(new_case_name)
    end
  end

  describe 'Delete case' do
    before do
      @params = { product_name: rand_product_name,
                  plan_name: rand_plan_name,
                  run_name: rand_run_name,
                  name: rand_result_set_name }
    end

    it 'Delete case by id' do
      @user.create_new_result_set(@params)
      @params[:name] = "NEW_#{@params[:name]}"
      result_set = @user.create_new_result_set(@params)
      case_pack = @user.get_cases_from_plan(plan_id: result_set.run.plan.id, suite_id: result_set.run.plan.product.suite.id)
      @user.delete_case(case_id: case_pack.cases.first.id, plan_id: result_set.run.plan.id)
      new_case_pack = @user.get_cases_from_plan(plan_id: result_set.run.plan.id, suite_id: result_set.run.plan.product.suite.id)
      expect(case_pack.cases.size).to eq(2)
      expect(new_case_pack.cases.size).to eq(1)
    end

    it 'Create cases and check existing in new plan' do
      @params[:name] = "First_#{@params[:name]}"
      @user.create_new_result_set(@params)
      @params[:name] = "Second_#{@params[:name]}"
      @user.create_new_result_set(@params)
      @params[:name] = "Third_#{@params[:name]}"
      @user.create_new_result_set(@params)

      @params[:plan_name] = "Other_plan_name_#{@params[:name]}"
      result_set = @user.create_new_result_set(@params)
      case_pack = @user.get_cases_from_plan(plan_id: result_set.run.plan.id, suite_id: result_set.run.plan.product.suite.id)
      expect(case_pack.cases.size).to eq(3)
    end

    it 'Delete case and check not existing in new plan' do
      @params[:name] = "First_#{@params[:name]}"
      first_result_set = @user.create_new_result_set(@params)
      @params[:name] = "Second_#{@params[:name]}"
      @user.create_new_result_set(@params)
      @params[:name] = "Third_#{@params[:name]}"
      @user.create_new_result_set(@params)

      case_pack = @user.get_cases_from_plan(plan_id: first_result_set.run.plan.id, suite_id: first_result_set.run.plan.product.suite.id)
      @user.delete_case(case_id: case_pack.cases.first.id, plan_id: first_result_set.run.plan.id)

      @params[:plan_name] = "Other_plan_name_#{@params[:name]}"
      result_set = @user.create_new_result_set(@params)

      case_pack_2 = @user.get_cases_from_plan(plan_id: result_set.run.plan.id, suite_id: result_set.run.plan.product.suite.id)
      expect(case_pack_2.cases.size).to eq(2)
    end

    # it 'result set will be delete if case delete' do
    #   result_set = @user.create_new_result_set(@params)
    #   case_pack = @user.get_cases(id: result_set.run.plan.product.suite.id)
    #   @user.delete_case(id: case_pack.cases.first.id)
    #   cases_after_deletind = @user.get_cases(id: result_set.run.plan.product.suite.id)
    #   result_set_pack = @user.get_result_sets(id: result_set.run.id)
    #   expect(cases_after_deletind.cases).to be_empty
    #   expect(result_set_pack.result_sets).to be_empty
    # end

    # it 'not delete case if case with this name is exist in other suite' do
    #   first_result_set = @user.create_new_result_set(@params)
    #   @params[:run_name] = rand_run_name
    #   second_result_set = @user.create_new_result_set(@params)
    #   case_pack = @user.get_cases(id: first_result_set.run.plan.product.suite.id)
    #   @user.delete_case(id: case_pack.cases.first.id)
    #   response_first = @user.get_result_set(id: first_result_set.id)
    #   response_second = @user.get_result_set(id: second_result_set.id)
    #   cases_after_deleting = @user.get_cases(id: first_result_set.run.plan.product.suite.id)
    #   expect(response_first.is_null).to be_truthy
    #   expect(response_second.is_null).to be_falsey
    #   expect(cases_after_deleting.cases.empty?).to be_truthy
    # end
  end
end
