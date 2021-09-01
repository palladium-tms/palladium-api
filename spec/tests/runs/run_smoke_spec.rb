require_relative '../../tests/test_management'
describe 'Run Smoke' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'Create new run' do
    it 'check creating new run, plan and product by run_name, plan_name and product_name' do
      params = {plan_name: rand_plan_name, product_name: rand_product_name, name: rand_run_name}
      run = @user.create_new_run(params)
      expect(run.response.code).to eq('200')
      expect(run.plan.product.name).to eq(params[:product_name])
      expect(run.plan.name).to eq(params[:plan_name])
      expect(run.name).to eq(params[:name])
    end

    it 'check creating new run and plan by plan_name, run_name and product_id' do
      @product = @user.create_new_product
      params = {plan_name: rand_plan_name, product_id: @product.id, name: rand_run_name}
      run = @user.create_new_run(params)
      expect(run.response.code).to eq('200')
      expect(run.plan.product.name).to eq(@product.name)
      expect(run.plan.name).to eq(params[:plan_name])
      expect(run.name).to eq(params[:name])
    end

    it 'check creating new run by plan_id and run_name' do
      @product = @user.create_new_product
      @plan = @user.create_new_plan(product_id: @product.id)
      params = {plan_id:  @plan.id, name: rand_run_name}
      run = @user.create_new_run(params)
      expect(run.response.code).to eq('200')
      expect(run.plan.name).to eq(@plan.name)
      expect(run.name).to eq(params[:name])
    end

    it 'check creating new run by plan_name and run_name' do
      @product = @user.create_new_product
      @plan = @user.create_new_plan(product_id: @product.id)
      params = {product_name: @product, plan_name:  @plan.name, name: rand_run_name}
      run = @user.create_new_run(params)
      expect(run.response.code).to eq('200')
      expect(run.plan.name).to eq(@plan.name)
      expect(run.name).to eq(params[:name])
    end
  end

  describe 'Show runs' do
    before :each do
      @product = @user.create_new_product
      @plan = @user.create_new_plan(product_id: @product.id)
      @run = @user.create_new_run(plan_id: @plan.id)
    end

    it 'Get runs by plan_id' do
      run_pack, _ = @user.get_runs(plan_id: @plan.id)
      expect(run_pack.runs.first.id).to eq(@run.id)
      expect(run_pack.runs.first.plan_id).to eq(@plan.id)
    end

    it 'Get one run | show method' do
      run_show = @user.get_run(id: @run.id)
      expect(@run.like_a?(run_show)).to be_truthy
    end
  end

  describe 'Delete Run' do
    before :each do
      @product = @user.create_new_product
      @plan = @user.create_new_plan(product_id: @product.id)
      @run = @user.create_new_run(plan_id: @plan.id)
    end

    it 'Delete run by run_id' do
      response = @user.delete_run(id: @run.id)
      run_after_deleting = @user.get_run(id: @run.id)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']).to be_empty
      expect(JSON.parse(response.body)['run']).to eq(@run.id)
      expect(JSON.parse(response.body)['run']).to eq(@run.id)
      expect(run_after_deleting.errors).to eq('run not found')
    end

    # it 'Delete run with result_sets by run_id' do
    #   result_set_name = http.random_name
    #   run = RunFunctions.create_new_run(http, plan_id: plan.id)[0]
    #   ResultSetFunctions.create_new_result_set(http, run_id: run.id,
    #                                                  result_set_name: result_set_name)[0]
    #   run_deleting_id = RunFunctions.delete_run(http, id: run.id)[0]
    #   run_after_deleting = RunFunctions.get_run(http, id: run.id)[0]
    #   result_set_after_deleting = ResultSetFunctions.get_result_sets(http, id: run.id)[0]
    #   expect(run.id).to eq(run_deleting_id)
    #   expect(run_after_deleting.errors).to eq('run not found')
    #   expect(result_set_after_deleting.result_sets).to be_empty
    # end
  end
end
