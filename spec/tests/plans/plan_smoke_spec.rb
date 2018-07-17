require_relative '../../tests/test_management'
http, product, plan, plan_name = nil
describe 'Plan Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  before :each do
    #---product creating
    product = ProductFunctions.create_new_product(http)[0]
  end

  describe 'Create new plan' do
    it 'check creating new plan with product_id' do
      correct_plan_name = http.random_name
      plan, _, code = PlanFunctions.create_new_plan(http, name: correct_plan_name,
                                                          product_id: product.id)
      expect(code).to eq('200')
      expect(plan.name).to eq(correct_plan_name)
      expect(plan.product_id).to eq(product.id)
    end

    it 'check creating new plan with product_name(it product is exists)' do
      plan, plan_name, code = PlanFunctions.create_new_plan(http, product_name: product.name)
      expect(code).to eq('200')
      expect(plan.name).to eq(plan_name)
      expect(plan.product_id).to eq(product.id)
    end

    it 'check creating new plan with product_name(it product is not exists)' do
      product_name = http.random_name
      plan, plan_name, code = PlanFunctions.create_new_plan(http, product_name: product_name)
      expect(code).to eq('200')
      expect(plan.name).to eq(plan_name)
      expect(plan.product_id).not_to be_nil
    end
  end

  describe 'Show plans' do
    before :each do
      plan = PlanFunctions.create_new_plan(http, product_name: product.name)[0]
    end

    it 'get plans by product id' do
      plan_pack, code = PlanFunctions.get_plans(http, product_id: plan.product_id)
      expect(code).to eq('200')
      expect(plan_pack.plans.count).to eq(1)
      expect(plan_pack.plans[0].name).to eq(plan.name)
      expect(plan_pack.plans[0].product_id).to eq(plan.product_id)
    end

    it 'get plans by product name' do
      plan_pack, code = PlanFunctions.get_plans(http, product_id: plan.product_id)
      expect(code).to eq('200')
      expect(plan_pack.plans.count).to eq(1)
      expect(plan_pack.plans[0].name).to eq(plan.name)
      expect(plan_pack.plans[0].product_id).to eq(product.id)
    end

    it 'get one plan | show method' do
      plan = PlanFunctions.create_new_plan(http, product_name: http.random_name)[0]
      plan_show, code = PlanFunctions.show_plan(http, id: plan.id)
      expect(code).to eq('200')
      expect(plan_show.like_a?(plan)).to be_truthy
    end
  end

  describe 'Delete Plan' do
    before :each do
      plan = PlanFunctions.create_new_plan(http, product_name: product.name)[0]
    end

    it 'check deleting plan' do
      plan_deleted_data = PlanFunctions.delete_plan(http, id: plan.id)[0]
      plan_pack = PlanFunctions.get_plans(http, product_id: plan.product_id)[0]
      expect(plan_deleted_data['plan']).to eq(plan.id)
      expect(plan_pack.plans).to be_empty
    end

    it 'check deleting plan with runs' do
      RunFunctions.create_new_run(http, plan_id: plan.id)
      response = PlanFunctions.delete_plan(http, id: plan.id)[0]
      plans = PlanFunctions.get_plans(http, product_id: plan.product_id)[0]
      expect(response['errors'].empty?).to be_truthy
      expect(response['plan']).to eq(plan.id)
      expect(plans.plans).to be_empty
    end
  end

  describe 'Edit Plan' do
    it 'edit plan after create' do
      plan = PlanFunctions.create_new_plan(http, product_name: product.name)[0]
      plan_name_for_updating = http.random_name
      plan_new = PlanFunctions.update_plan(http, id: plan.id, plan_name: plan_name_for_updating)[0]
      expect(plan_new.id).to eq(plan.id)
      expect(plan_new.name).to eq(plan_name_for_updating)
    end
  end
end
