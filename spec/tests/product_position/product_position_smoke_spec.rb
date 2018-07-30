require_relative '../../tests/test_management'
http, user_data = nil
describe 'Product Position Smoke' do
  before :each do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    data = AuthFunctions.create_new_account
    http.request(data[0])
    user_data = data[1]
    token = AuthFunctions.get_token(user_data[:email], user_data[:password])
    http = Http.new(token: token)
  end

  describe 'Set product position with phantom data' do
    it 'setting product position with correct data' do
      responce = ProductPosition.set_product_position(http, product_position: [1, 2, 3, 4, 5])
      response = JSON.parse(responce.body)
      expect(response['user']['email']).to eq(user_data[:email])
      expect(response['user']['product_position']).to eq([1, 2, 3, 4, 5])
    end

    it 'setting product position with incorrect data' do
      responce = ProductPosition.set_product_position(http, product_position: 'error')
      response = JSON.parse(responce.body)
      expect(response['user'].nil?).to be_truthy
      expect(response['product_position_errors']).to eq('product position must be array')
    end

    it 'setting product position without data' do
      responce = ProductPosition.set_product_position(http,{})
      response = JSON.parse(responce.body)
      expect(response['user'].nil?).to be_truthy
      expect(response['product_position_errors']).to eq('product position must be array')
    end

    it 'Set product position after product create' do
      5.times { ProductFunctions.create_new_product_and_parse(http) }
      products_id = ProductFunctions.get_all_products(http).products.map(&:id)
      shuffled_products = products_id.sample(products_id.size)
      ProductPosition.set_product_position(http, product_position: shuffled_products)
      new_products_list = ProductFunctions.get_all_products(http).products.map(&:id)
      expect(new_products_list).to eq(shuffled_products)
    end
  end
end
