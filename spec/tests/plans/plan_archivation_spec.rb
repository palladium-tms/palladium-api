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
      response = PlanFunctions.create_new_plan(http, name: correct_plan_name,
                                                     product_id: product['id'])[0]
      plan = PlanFunctions.archive_plan(http, JSON.parse(response.body)['plan']['id'])
      expect(response.code).to eq('422')
      expect(JSON.parse(response.body)['plan_errors']).to eq('product creating error')
      expect(JSON.parse(response.body)['product_errors']).not_to be_empty
    end

  end

end
