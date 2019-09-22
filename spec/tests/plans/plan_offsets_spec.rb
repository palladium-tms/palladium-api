require_relative '../../tests/test_management'
describe 'Plan Smoke' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  before :each do
    @product = @user.create_new_product
    10.times { @user.create_new_plan(product_name: @product.name) }
  end

  describe 'Plan limits check' do
    it 'check for showing only limited plans' do
      plans = @user.get_plans(product_id: @product.id).plans
      @plan = @user.create_new_plan(product_name: @product.name)
      new_plans = @user.get_plans(product_id: @product.id).plans
      expect(plans.count).to eq(3)
      expect(new_plans.count).to eq(3)
      expect(new_plans.first.like_a?(@plan)).to be_truthy
    end

    it 'check for getting plans with 0 offset' do
      6.times { @user.create_new_plan(product_name: @product.name) }
      plans_with_offset = @user.get_plans(product_id: @product.id, offset: 0).plans
      plans = @user.get_plans(product_id: @product.id).plans
      expect(plans.count).to eq(3)
      expect(plans_with_offset.count).to eq(3)
      expect(plans_with_offset.map(&:id)).to eq(plans.map(&:id))
    end

    it 'check for getting plans with offset' do
      6.times { @user.create_new_plan(product_name: @product.name) }
      plans_with_offset_zero = @user.get_plans(product_id: @product.id, offset: 0)
      plans_with_offset_two = @user.get_plans(product_id: @product.id, offset: 2)
      plans_with_offset_seven = @user.get_plans(product_id: @product.id, offset: 6)
      expect(plans_with_offset_zero.plans.count).to eq(3)
      expect(plans_with_offset_two.plans.count).to eq(3)
      expect(plans_with_offset_seven.plans.count).to eq(3)
      expect(plans_with_offset_zero.plans.last.like_a?(plans_with_offset_two.plans.first)).to be_truthy
    end

    it 'check for getting plans with bad offset (-1)' do
      6.times { @user.create_new_plan(product_name: @product.name) }
      plans_stack = @user.get_plans(product_id: @product.id, offset: -1)
      expect(plans_stack.response.code).to eq('200')
      expect(plans_stack.plans).to be_empty
    end

    it 'check for getting plans with bad offset (string)' do
      6.times { @user.create_new_plan(product_name: @product.name) }
      plans_stack = @user.get_plans(product_id: @product.id, offset: 'string offset')
      expect(plans_stack.response.code).to eq('200')
      expect(plans_stack.plans.count).to eq(3)
    end
  end

  describe 'Get plans before plan_with id' do
    it 'check with first plan_id' do
      6.times { @user.create_new_plan(product_name: @product.name) }
      plan = @user.create_new_plan(product_name: @product.name)
      plans_pack = @user.get_plans(product_id: @product.id, plan_id: plan.id).plans
      expect(plans_pack.count).to eq(3)
      expect(plans_pack.first.id).to eq(plan.id)
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
      plan = @user.create_new_plan(product_name: @product.name)
      plans_pack = @user.get_plans(product_id: @product.id, plan_id: 100_500)
      expect(plans_pack.plans.count).to eq(3)
      expect(plans_pack.plans.first.id).to eq(plan.id)
    end

    it 'check with incorrect plan_id type' do
      9.times { @user.create_new_plan(product_name: @product.name) }
      plan = @user.create_new_plan(product_name: @product.name)
      plans_pack = @user.get_plans(product_id: @product.id, plan_id: 'string')
      expect(plans_pack.plans.count).to eq(3)
      expect(plans_pack.plans.first.id).to eq(plan.id)
    end
  end
end