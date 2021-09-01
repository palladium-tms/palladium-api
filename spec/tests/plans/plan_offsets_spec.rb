require_relative '../../tests/test_management'
describe 'Plan Smoke' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  before do
    @product = @user.create_new_product
    10.times { @user.create_new_plan(product_name: @product.name) }
  end

  describe 'Plan limits check' do
    it 'check for showing only limited plans' do
      plans = @user.get_plans(product_id: @product.id).plans
      @plan = @user.create_new_plan(product_name: @product.name)
      new_plans = @user.get_plans(product_id: @product.id).plans
      expect(plans.count).to eq(6)
      expect(new_plans.count).to eq(6)
      expect(new_plans.first).to be_like_a(@plan)
    end
  end

  describe 'Get plans before plan_with id' do
    it 'check with first plan_id' do
      plan = @user.create_new_plan(product_name: @product.name)
      6.times { @user.create_new_plan(product_name: @product.name) }
      plans_pack = @user.get_plans(product_id: @product.id, plan_id: plan.id).plans
      expect(plans_pack.count).to eq(7)
      expect(plans_pack.last.id).to eq(plan.id)
    end

    it 'check with 7th plan_id' do
      3.times { @user.create_new_plan(product_name: @product.name) }
      plan = @user.create_new_plan(product_name: @product.name)
      6.times { @user.create_new_plan(product_name: @product.name) }
      plans_pack = @user.get_plans(product_id: @product.id, plan_id: plan.id)
      expect(plans_pack.plans.count).to eq(7)
      expect(plans_pack.plans.last.id).to eq(plan.id)
    end

    it 'check with wrong plan_id' do
      9.times { @user.create_new_plan(product_name: @product.name) }
      @user.create_new_plan(product_name: @product.name)
      plans_pack = @user.get_plans(product_id: @product.id, plan_id: 100_500)
      expect(plans_pack.plans.count).to eq(0)
    end

    it 'check with incorrect plan_id type' do
      9.times { @user.create_new_plan(product_name: @product.name) }
      plan = @user.create_new_plan(product_name: @product.name)
      plans_pack = @user.get_plans(product_id: @product.id, plan_id: 'string')
      expect(plans_pack.plans.count).to eq(6)
      expect(plans_pack.plans.first.id).to eq(plan.id)
    end
  end
end
