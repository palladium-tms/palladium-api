require_relative '../../tests/test_management'
http, token = nil
describe 'Product Smoke' do
  before :all do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    token = AuthFunctions.create_user_and_get_token
  end
  describe 'Create new product' do
    it 'check creating new product with correct user_data and correct product_data' do
      request = Net::HTTP::Post.new('/api/product_new','Authorization' => token)
      corrent_product_name = 30.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({"product_data[name]": corrent_product_name})
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['product']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['product']['name']).to eq(corrent_product_name)
    end

    it 'check creating new product with correct user_data and exists correct product_data' do
      product = ProductFunctions.create_new_product(token)
      http.request(product[0]) # first creating
      response = http.request(product[0]) # second creating
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['product']['id']).to be_truthy
      expect(JSON.parse(response.body)['product']['name']).to eq(product[1])
    end
  end

  describe 'Delete product' do
    it 'check deleting product after product create' do
      product = ProductFunctions.create_new_product(token)
      new_product_response = http.request(product[0])
      product_id_for_deleting = JSON.parse(new_product_response.body)['product']['id']
      request = ProductFunctions.delete_product(token, product_id_for_deleting)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['product']).to eq(product_id_for_deleting.to_s)
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
    end

    it 'delete product with plans' do
      product = ProductFunctions.create_new_product(token)
      product_id_for_deleting = JSON.parse(http.request(product[0]).body)['product']['id']
      products_before_deleting = ProductFunctions.get_all_products(token)
      request, plan_name = PlanFunctions.create_new_plan(token: token, product_id: product_id_for_deleting)
      http.request(request)
      request = ProductFunctions.delete_product(token, product_id_for_deleting)
      response = http.request(request)
      products = ProductFunctions.get_all_products(token)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['product']).to eq(product_id_for_deleting.to_s)
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(products_before_deleting.keys - products.keys).to eq([product_id_for_deleting])
      expect(products[product_id_for_deleting].nil?).to be_truthy
    end
  end

  describe 'Get Products' do
    it 'get all products after creating' do
      product = ProductFunctions.create_new_product(token)
      new_product_data = http.request(product[0])
      products = ProductFunctions.get_all_products(token)
      expect(products[JSON.parse(new_product_data.body)['product']['id']]['name']).to eq(JSON.parse(new_product_data.body)['product']['name'])
    end
  end

  describe 'Edit product' do
    it 'edit product after creating' do
      product = ProductFunctions.create_new_product(token)
      product_name_for_updating = 30.times.map { StaticData::ALPHABET.sample }.join
      new_product_data = http.request(product[0])
      product_data = {id: JSON.parse(new_product_data.body)['product']['id'], name: product_name_for_updating}
      request = ProductFunctions.update_product(token, product_data)
      response = http.request(request)
      products = ProductFunctions.get_all_products(token)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(products[JSON.parse(new_product_data.body)['product']['id']]['name']).to eq(product_name_for_updating)
    end
  end
end