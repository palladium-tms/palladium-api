require_relative '../../tests/test_management'
describe 'Suites Smoke' do
  before :each do
    @user = AccountFunctions.create_and_parse
    @user.login
    @params = {plan_name: rand_plan_name, product_name: rand_product_name,
               run_name: rand_run_name, name: rand_run_name}
  end

  describe 'Create suite' do
    it 'check creating new suite after run created' do
      run = @user.create_new_run(plan_name: rand_plan_name, product_name: rand_product_name)
      _, suite_pack = @user.get_runs(plan_id: run.plan.id)
      expect(suite_pack.suites.first.name).to eq(run.name)
    end
  end

  describe 'Get suites' do
    it 'check getting suite' do
      product_name = rand_product_name
      plan_name = rand_plan_name
      run1 = @user.create_new_run(plan_name: plan_name, product_name: product_name)
      run2 = @user.create_new_run(plan_name: plan_name, product_name: product_name)
      run3 = @user.create_new_run(plan_name: plan_name, product_name: product_name)
      _, suite_pack = @user.get_runs(plan_id: run3.plan.id)
      expect(suite_pack.suites.map(&:name) & [run1.name, run2.name, run3.name]).to eq([run1.name, run2.name, run3.name])
    end
  end

  describe 'Update suite' do
    it 'check update suite' do
      run = @user.create_new_run(plan_name: @params[:plan_name], product_name: @params[:product_name])
      new_suite_name = rand_run_name
      new_suite = @user.update_suite(id: run.plan.product.suite.id, name: new_suite_name)
      _, suite_pack = @user.get_runs(plan_id: run.plan.id)
      expect(new_suite.name).to eq(new_suite_name)
      expect(suite_pack.suites.first.name).to eq(new_suite_name)
    end

    it 'check update suite and runs' do
      run = @user.create_new_run(plan_name: @params[:plan_name], product_name: @params[:product_name])
      new_suite_name = rand_run_name
      @user.update_suite(id: run.plan.product.suite.id, name: new_suite_name)
      run_pack, _ = @user.get_runs(plan_id: run.plan.id)
      expect(run_pack.runs.first.name).to eq(new_suite_name)
    end

    it 'check update suite and runs only in one product' do
      run_name = rand_run_name
      new_suite_name = rand_run_name
      first_run = @user.create_new_run(name: run_name, plan_name: @params[:plan_name], product_name: rand_product_name)
      second_run = @user.create_new_run(name: run_name, plan_name: @params[:plan_name], product_name: rand_product_name)
      new_suite = @user.update_suite(id: first_run.plan.product.suite.id, name: new_suite_name)
      runs_in_other_product, _ = @user.get_runs(plan_id: second_run.plan.id)
      expect(new_suite.name).to eq(new_suite_name)
      expect(runs_in_other_product.runs.first.name).to eq(second_run.name)
    end
  end

  describe 'Delete suite' do
    it 'check deleting suite' do
      @params = {plan_name: rand_plan_name, product_name: rand_product_name,
                 run_name: rand_run_name, name: rand_run_name}
      run = @user.create_new_run(@params)
      @params[:name] = "NEW_#{@params[:name]}"
      @user.create_new_run(@params)
      _, suite_pack_before = @user.get_runs(plan_id: run.plan.id)
      @user.delete_suite(suite_id: suite_pack_before.suites.first.id, plan_id: run.plan.id) # deleting
      _, suites_pack = @user.get_runs(plan_id: run.plan.id)
      expect(suite_pack_before.suites.size).to eq(2)
      expect(suites_pack.suites.size).to eq(1)
    end

    it 'check suite not existed in new plan after deleting' do
      product_name = rand_product_name
      plan_name = rand_plan_name
      run_for_delete = @user.create_new_run({product_name: product_name, plan_name: plan_name, name: rand_run_name})
      run_for_stay = @user.create_new_run({product_name: product_name, plan_name: plan_name, name: rand_run_name})
      _, suite_pack_before = @user.get_runs(plan_id: run_for_delete.plan.id)
      @user.delete_suite(suite_id: suite_pack_before.suites.first.id, plan_id: run_for_delete.plan.id) # deleting
      new_plan = @user.create_new_plan({product_name: product_name})
      _, suite_pack_after = @user.get_runs(plan_id: new_plan.id)
      expect(suite_pack_before.suites.size).to eq(2)
      expect(suite_pack_after.suites.size).to eq(1)
      expect(run_for_stay.name).to eq(suite_pack_after.suites[0].name)
    end

    # it 'check deleting all suites if product is deleted' do
    #   product = @user.create_new_product
    #   product = @user.create_new_run(plan_name: rand_run_name, product_name: product.name)
    #   @user.delete_product(product.id)
    #   suite_pack = @user.get_suites(id: product.id)
    #   expect(suite_pack.suites).to be_empty
    # end

    # it 'Delete run after suite delete' do
    #   run = @user.create_new_run(plan_name: rand_plan_name, product_name: rand_product_name)
    #   @user.delete_suite(id: run.plan.product.suite.id)
    #   suite_pack = @user.get_suites(id: run.plan.product.id)
    #   run_pack, _ = @user.get_runs(id: run.plan.id)
    #   expect(suite_pack.suites).to be_empty
    #   expect(run_pack.runs).to be_empty
    # end

    # it 'check deleting all runs after suite delete' do
    #   product_name = rand_product_name
    #   run = @user.create_new_run(plan_name: rand_plan_name, product_name: product_name)
    #   run2 = @user.create_new_run(plan_name: rand_plan_name, product_name: product_name)
    #   @user.delete_suite(id: run.plan.product.suite.id)
    #   suite_pack = @user.get_suites(id: run.plan.product.id)
    #   run_pack, _ = @user.get_runs(id: run.plan.id)
    #   run_pack2, _ = @user.get_runs(id: run2.plan.id)
    #   expect(suite_pack.suites.count).to eq(1)
    #   expect(run_pack.runs.count).to eq(0)
    #   expect(run_pack2.runs.count).to eq(1)
    # end
  end
end
