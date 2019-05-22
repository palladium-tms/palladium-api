require_relative '../../tests/test_management'
describe 'Product Validation' do
  before :all do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'Create new product' do
    it 'Create product with empty name' do
      product = @user.create_new_product('')
      expect(product.product_errors).to eq(['name cannot be empty'])
    end

    it 'Create product with spaces in name' do
      product = @user.create_new_product('  ')
      expect(product.product_errors).to eq(['name cannot contains only spaces'])
    end

    it 'Create product without name' do
      response = @user.post_request('/api/product_new', product_data: {})
      expect(JSON.parse(response.body)['product_errors']).to eq(['name of product_data not found'])
    end

    it 'Create product without product data' do
      response = @user.post_request('/api/product_new')
      expect(JSON.parse(response.body)['product_errors']).to eq(['product_data not found'])
    end
  end

  describe 'Change product name' do
    it 'Change product name to empty' do
      product = @user.create_new_product
      product_updated = @user.update_product(product.id, '')
      expect(product_updated.product_errors).to eq('name' => ['cannot be empty'])
    end
  end
end
