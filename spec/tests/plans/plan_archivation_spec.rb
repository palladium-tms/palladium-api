require_relative '../../tests/test_management'
http, product = nil
describe 'Plan Archivation' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'Archive plans | plan check' do
    before :each do
      #---product creating
      product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
    end

    it 'Create plan, not archive by default' do
      correct_plan_name = http.random_name
      plan = PlanFunctions.create_new_plan(http, name: correct_plan_name,
                                                 product_id: product['id'])[0]
      plan, code = PlanFunctions.archive_plan(http, plan.id)
      expect(code).to eq('200')
      expect(plan.is_archived).to be_truthy
    end

    # it 'Archive  plan and run' do
    #   correct_plan_name = http.random_name
    #   plan = PlanFunctions.create_new_plan(http, name: correct_plan_name,
    #                                              product_id: product['id'])[0]
    #   responce = PlanFunctions.archive_plan(http, plan.id)
    #   expect(responce[:code]).to eq('200')
    #   expect(responce['plan']['is_archived']).to be_truthy
    # end
  end
end
