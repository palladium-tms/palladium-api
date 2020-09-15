require_relative '../../tests/test_management'
describe 'History Smoke' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
  end
  # Fixme: add more checks for history
  describe 'Get history from case id' do
    before :each do
      @params = {product_name: rand_product_name,
                 plan_name: rand_plan_name,
                 run_name: rand_run_name,
                 result_set_name: rand_result_set_name,
                 message: rand_message,
                 status: 'Passed'}
    end
    it '1. Check creating new result with all other elements' do
      3.times do
        @first_result ||= @user.create_new_result(@params)
      end
      @params[:plan_name] = rand_plan_name
      3.times do
        @second_result ||= @user.create_new_result(@params)
      end
      case_pack = @user.get_cases(id: @first_result.product.suite.id)
      result_sets_history = @user.case_history(id: case_pack.cases.first.id)
      expect(result_sets_history.histories.size).to eq(2)
      expect(result_sets_history.plan_exist?(@first_result.plan.id)).to be_truthy
      expect(result_sets_history.plan_exist?(@second_result.plan.id)).to be_truthy
      expect(result_sets_history.run_exist?(@first_result.run.id)).to be_truthy
      expect(result_sets_history.run_exist?(@second_result.run.id)).to be_truthy
    end

    it 'Get history only by 30 plans' do
      results = []
      35.times do
        # sleep 1
        results << @user.create_new_result(@params)
        @params[:message] = rand_message
        @params[:plan_name] = rand_plan_name
      end
      case_pack = @user.get_cases(id: results[0].product.suite.id)
      history_pack = @user.case_history(id: case_pack.cases.first.id)
      expect(history_pack.histories.size).to eq(30)
      expect(history_pack.get_youngest_by_plan).to eq(results.last.plan.id)
      expect(history_pack.get_oldest_by_plan).to eq(results[5].plan.id)
    end
  end

  describe 'Get history from result set id' do
    before :each do
      @params = {product_name: rand_product_name,
                 plan_name: rand_plan_name,
                 run_name: rand_run_name,
                 result_set_name: rand_result_set_name,
                 message: rand_message,
                 status: 'Passed'}
    end
    it '1. Check creating new result with all other elements' do
      3.times do
        @first_result ||= @user.create_new_result(@params)
      end
      @params[:plan_name] = rand_plan_name
      3.times do
        @second_result ||= @user.create_new_result(@params)
      end
      result_sets_history = @user.case_history(result_set_id: @first_result.result_set.id)
      expect(result_sets_history.histories.size).to eq(2)
      expect(result_sets_history.plan_exist?(@first_result.plan.id)).to be_truthy
      expect(result_sets_history.plan_exist?(@second_result.plan.id)).to be_truthy
      expect(result_sets_history.run_exist?(@first_result.run.id)).to be_truthy
      expect(result_sets_history.run_exist?(@second_result.run.id)).to be_truthy
    end
  end
end
