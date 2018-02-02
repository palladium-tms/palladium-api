require_relative '../../tests/test_management'
http = nil
describe 'Product Validation' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end
  describe 'Create new product' do
    it 'Create product with empty name' do
      res_new_product = ProductFunctions.create_new_product(http, '')[0]
      expect(JSON.parse(res_new_product.body)['product_errors']).to eq(['name cannot be empty'])
    end

    it 'Create product with spaces in name' do
      res_new_product = ProductFunctions.create_new_product(http, '  ')[0]
      expect(JSON.parse(res_new_product.body)['product_errors']).to eq(['name cannot contains only spaces'])
    end

    it 'Create product without name' do
      response = http.post_request('/api/product_new', product_data: {})
      expect(JSON.parse(response.body)['product_errors']).to eq(['name of product_data not found'])
    end

    it 'Create product without product data' do
      response = http.post_request('/api/product_new')
      expect(JSON.parse(response.body)['product_errors']).to eq(['product_data not found'])
    end
  end

  describe 'Change product name' do
    it 'Change product name to empty' do
      res_new_product = ProductFunctions.create_new_product(http)[0]
      updated_product = ProductFunctions.update_product(http, JSON.parse(res_new_product.body)['product']['id'], '')
      expect(JSON.parse(updated_product.body)['product_errors']).to eq('name' => ['cannot be empty'])
    end
  end
end
