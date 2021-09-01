# frozen_string_literal: true

require_relative '../../tests/test_management'
describe 'Plan Validation' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'Create new plan and product' do
    it 'Create product and plan one command with empty product name' do
      plan = @user.create_new_plan(name: rand_plan_name, product_name: '')
      expect(plan.response.code).to eq('422')
      expect(plan.plan_errors).to eq('product creating error')
      expect(plan.is_null).to be_truthy
    end

    it 'Create product and plan one command with empty plan name' do
      plan = @user.create_new_plan(name: '', product_name: rand_product_name)
      expect(plan.response.code).to eq('422')
      expect(plan.plan_errors).to eq(['name cannot be empty'])
    end

    it 'Create product and plan one command with empty plan name and product name' do
      plan = @user.create_new_plan(name: '', product_name: '')
      expect(plan.response.code).to eq('422')
      expect(plan.plan_errors).to eq('product creating error')
      expect(plan.product.product_errors).to eq(['name cannot be empty'])
    end

    it 'Create product and plan with spaces name' do
      plan = @user.create_new_plan(name: '   ', product_name: '   ')
      expect(plan.response.code).to eq('422')
      expect(plan.plan_errors).to eq('product creating error')
      expect(plan.product.product_errors).to eq(['name cannot contains only spaces'])
    end
  end

  describe 'Edit plan validation' do
    it 'Change plan name to empty' do
      plan = @user.create_new_plan(product_name: rand_product_name)
      plan_new = @user.update_plan(id: plan.id, plan_name: '')
      expect(plan_new.plan_errors).to eq(['name cannot be empty'])
    end
  end
end
