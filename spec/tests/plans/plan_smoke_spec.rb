require_relative '../../tests/test_management'
describe 'Plan Smoke' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  before do
    @product = @user.create_new_product
  end

  describe 'Create new plan' do
    it 'check creating new plan with product_id' do
      plan = @user.create_new_plan(product_id: @product.id)
      expect(plan.response.code).to eq('200')
      expect(plan.product.id).to eq(@product.id)
    end

    it 'check creating new plan with product_name(it product is exists)' do
      plan = @user.create_new_plan(product_name: @product.name)
      expect(plan.response.code).to eq('200')
      expect(plan.product_id).to eq(@product.id)
    end

    it 'check creating new plan with product_name(it product is not exists)' do
      plan = @user.create_new_plan(product_name: rand_product_name)
      expect(plan.response.code).to eq('200')
      expect(plan.product_id).not_to be_nil
    end

    it 'check creating new plan with manual fields' do
      plan_api_created = @user.create_new_plan(product_name: rand_product_name, api_created: true)
      plan_manual_created = @user.create_new_plan(product_name: rand_product_name, api_created: false)
      plan_api_default = @user.create_new_plan(product_name: rand_product_name)
      expect(plan_api_created.response.code).to eq('200')
      expect(plan_manual_created.response.code).to eq('200')
      expect(plan_api_default.response.code).to eq('200')
      expect(plan_api_created.api_created).to be_truthy
      expect(plan_manual_created.api_created).to be_falsey
      expect(plan_api_default.api_created).to be_truthy
    end
  end

  describe 'Show plans' do
    before do
      @plan = @user.create_new_plan(product_name: @product.name)
    end

    it 'get plans by product id' do
      plan_pack = @user.get_plans(product_id: @plan.product_id)
      expect(plan_pack.response.code).to eq('200')
      expect(plan_pack.plans.count).to eq(1)
      expect(plan_pack.plans[0].name).to eq(@plan.name)
      expect(plan_pack.plans[0].product_id).to eq(@plan.product_id)
    end

    it 'get plans by product name' do
      plan_pack = @user.get_plans(product_id: @plan.product_id)
      expect(plan_pack.response.code).to eq('200')
      expect(plan_pack.plans.count).to eq(1)
      expect(plan_pack.plans[0].name).to eq(@plan.name)
      expect(plan_pack.plans[0].product_id).to eq(@product.id)
    end

    it 'get one plan | show method' do
      plan = @user.show_plan(id: @plan.id)
      expect(plan.response.code).to eq('200')
      expect(plan).to be_like_a(@plan)
    end
  end

  describe 'Delete Plan' do
    before do
      @plan = @user.create_new_plan(product_name: @product.name)
    end

    it 'check deleting plan' do
      response = @user.delete_plan(id: @plan.id)
      plan_pack = @user.get_plans(product_id: @plan.product_id)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['plan']['id']).to eq(@plan.id)
      expect(JSON.parse(response.body)['errors']).to be_empty
      expect(plan_pack.plans).to be_empty
    end

    it 'check deleting plan with runs' do
      @user.create_new_run(plan_id: @plan.id)
      response = @user.delete_plan(id: @plan.id)
      plans = @user.get_plans(product_id: @plan.product_id)
      expect(JSON.parse(response.body)['errors']).to be_empty
      expect(JSON.parse(response.body)['plan']['id']).to eq(@plan.id)
      expect(plans.plans).to be_empty
    end
  end

  describe 'Edit Plan' do
    before do
      @plan = @user.create_new_plan(product_name: @product.name)
    end

    it 'edit plan after create' do
      new_name = rand_plan_name
      plan_new = @user.update_plan(id: @plan.id, plan_name: new_name)
      expect(plan_new.plan_errors).to be_nil
      expect(plan_new.id).to eq(@plan.id)
      expect(plan_new.name).to eq(new_name)
    end
  end
end
