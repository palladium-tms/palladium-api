# frozen_string_literal: true

require_relative '../tests/test_management'

http, = nil
cases = []
describe 'Status Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
    products = JSON.parse(ProductFunctions.get_all_products(http).body)['products'].map! { |product| product['id'] }
    suites = []
    products.each do |product_id|
      suites += JSON.parse(SuiteFunctions.get_suites(http, id: product_id).body)['suites'].map! { |suite| suite['id'] }
    end
    suites.each do |suite_id|
      cases += JSON.parse(CaseFunctions.get_cases(http, id: suite_id).body)['cases'].map! { |this_case| this_case['id'] }
    end
  end

  describe 'History' do
    it 'check_history' do
      cases.each do |case_id|
        logger.info("Case id: #{case_id}")
        responce = HistoryFunctions.case_history(http, case_id)
        expect(responce.code).to eq('200')
      end
    end
  end
end
