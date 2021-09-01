require_relative '../../tests/test_management'
describe 'Result Set Smoke' do
  before do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'Create new result_sets' do
    before do
      @params = { plan_name: rand_plan_name, product_name: rand_product_name, run_name: rand_run_name, name: rand_run_name }
    end

    it '1. Create product, plan, run and result set in one time' do
      result_set = @user.create_new_result_set(@params)
      expect(result_set.run.plan.product.name).to eq(@params[:product_name])
      expect(result_set.run.plan.name).to eq(@params[:plan_name])
      expect(result_set.run.name).to eq(@params[:run_name])
      expect(result_set.name).to eq(@params[:name])
    end

    it '2. Create plan, run and result set in one time' do
      product = @user.create_new_product
      @params[:product_name] = product.name
      result_set = @user.create_new_result_set(@params)
      expect(result_set.run.plan.product.name).to eq(product.name)
      expect(result_set.run.plan.name).to eq(@params[:plan_name])
      expect(result_set.run.name).to eq(@params[:run_name])
      expect(result_set.name).to eq(@params[:name])
    end

    it '3. Create run and result set in one time' do
      product = @user.create_new_product
      plan = @user.create_new_plan(product_name: product.name)
      @params[:product_name] = product.name
      @params[:plan_name] = plan.name
      result_set = @user.create_new_result_set(@params)
      expect(result_set.run.plan).to be_like_a(plan)
      expect(result_set.run.name).to eq(@params[:run_name])
      expect(result_set.name).to eq(@params[:name])
    end

    it '4. Create result set in one time' do
      product = @user.create_new_product
      plan = @user.create_new_plan(product_name: product.name)
      run = @user.create_new_run(plan_id: plan.id)
      name = rand_run_name
      result_set = @user.create_new_result_set(run_id: run.id, name: name)
      expect(result_set.run.id).to eq(run.id)
      expect(result_set.name).to eq(name)
    end
  end

  describe 'Show result_set' do
    before do
      @result_set = @user.create_new_result_set(plan_name: rand_plan_name, product_name: rand_product_name, run_name: rand_run_name, name: rand_run_name)
    end

    it 'get result_sets by run_id' do
      result_set_pack = @user.get_result_sets(id: @result_set.run.id)
      expect(result_set_pack.result_sets.first).to be_like_a(@result_set)
      expect(result_set_pack.result_sets.first.id).to eq(@result_set.id)
      expect(result_set_pack.result_sets.first.run_id).to eq(@result_set.run.id)
    end

    it 'get result_set | show method' do
      result_set_show = @user.get_result_set(id: @result_set.id)
      expect(@result_set).to be_like_a(result_set_show)
    end
  end

  describe 'Delete result_set' do
    it 'Delete result set' do
      @result_set = @user.create_new_result_set(plan_name: rand_plan_name, product_name: rand_product_name, run_name: rand_run_name, name: rand_run_name)
      delete_responce = @user.delete_result_set(id: @result_set.id)
      result_ser_after_deleting = @user.get_result_set(id: @result_set.id)
      expect(JSON.parse(delete_responce.body)['result_set']['id']).to eq(@result_set.id)
      expect(result_ser_after_deleting.response.code).to eq('200')
    end

    it 'Delete result set from archived plan' do
      @result_set = @user.create_new_result_set(plan_name: rand_plan_name, product_name: rand_product_name, run_name: rand_run_name, name: rand_run_name)
      @user.create_new_result_set(plan_name: rand_plan_name, product_name: rand_product_name, run_name: rand_run_name, name: rand_run_name)
      delete_responce = @user.delete_result_set(id: @result_set.id)
      @user.archive_plan(id: @result_set.run.plan.id)
      result_ser_after_deleting = @user.get_result_set(id: @result_set.id)
      expect(JSON.parse(delete_responce.body)['result_set']['id']).to eq(@result_set.id)
      expect(result_ser_after_deleting.response.code).to eq('200')
    end
  end
end
