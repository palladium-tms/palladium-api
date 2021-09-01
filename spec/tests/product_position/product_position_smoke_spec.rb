require_relative '../../tests/test_management'
describe 'Product Position Smoke' do
  before :each do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'Set product position with phantom data' do
    it 'setting product position with correct data' do
      responce = @user.set_product_position(product_position: [1, 2, 3, 4, 5])
      response = JSON.parse(responce.body)
      expect(response['user']['email']).to eq(@user.email)
      expect(response['user']['product_position']).to eq([1, 2, 3, 4, 5])
    end

    it 'setting product position with incorrect data' do
      responce = @user.set_product_position(product_position: 'error')
      response = JSON.parse(responce.body)
      expect(response['user'].nil?).to be_truthy
      expect(response['product_position_errors']).to eq('product position must be array')
    end

    it 'setting product position without data' do
      responce = @user.set_product_position({})
      response = JSON.parse(responce.body)
      expect(response['user'].nil?).to be_truthy
      expect(response['product_position_errors']).to eq('product position must be array')
    end

    it 'Set product position after product create' do
      5.times { @user.create_new_product }
      products_id = @user.get_all_products.products.map(&:id)
      shuffled_products = products_id.sample(products_id.size)
      @user.set_product_position(product_position: shuffled_products)
      new_products_list = @user.get_all_products.products.map(&:id)
      expect(new_products_list).to eq(shuffled_products)
    end
  end
end
