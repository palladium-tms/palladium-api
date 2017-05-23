require_relative '../../tests/test_management'
http, account = nil
describe 'Product Smoke' do
  before :all do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
  end
  describe 'Create new product' do
    it 'check creating new product with correct user_data and correct product_data' do
      request = Net::HTTP::Post.new('/api/product_new','Authorization' => StaticData::TOKEN)
      corrent_product_name = 30.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({"product_data[name]": corrent_product_name})
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['product']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['product']['name']).to eq(corrent_product_name)
    end

    it 'check creating new product with correct user_data and exists correct product_data' do
      product = ProductFunctions.create_new_product(StaticData::TOKEN)
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
      product = ProductFunctions.create_new_product(StaticData::TOKEN)
      new_product_response = http.request(product[0])
      product_id_for_deleting = JSON.parse(new_product_response.body)['product']['id']
      request = ProductFunctions.delete_product(StaticData::TOKEN, product_id_for_deleting)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['product']).to eq(product_id_for_deleting.to_s)
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
    end
  end

  describe 'Get Products' do
    it 'get all products after creating' do
      product = ProductFunctions.create_new_product(StaticData::TOKEN)
      new_product_data = http.request(product[0])
      products = ProductFunctions.get_all_products(StaticData::TOKEN)
      expect(products[JSON.parse(new_product_data.body)['product']['id']]['name']).to eq(JSON.parse(new_product_data.body)['product']['name'])
    end
  end

  describe 'Edit product' do
    it 'edit product after creating' do
      product = ProductFunctions.create_new_product(StaticData::TOKEN)
      product_name_for_updating = 30.times.map { StaticData::ALPHABET.sample }.join
      new_product_data = http.request(product[0])
      product_data = {id: JSON.parse(new_product_data.body)['product']['id'], name: product_name_for_updating}
      request = ProductFunctions.update_product(StaticData::TOKEN, product_data)
      response = http.request(request)
      products = ProductFunctions.get_all_products(StaticData::TOKEN)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(products[JSON.parse(new_product_data.body)['product']['id']]['name']).to eq(product_name_for_updating)
    end
  end

  describe 'Show Product' do
    it 'get product after creating with without user_data' do
      email = 10.times.map { StaticData::ALPHABET.sample }.join
      password = 7.times.map { StaticData::ALPHABET.sample }.join
      new_product = ProductFunctions.create_new_product(account)
      new_product_data = http.request(new_product[0])
      product_id = JSON.parse(new_product_data.body)['product']['id']
      params = {"user_data[email]": email, "user_data[password]":  password,  "product_data[id]": product_id}
      uri = URI(StaticData::MAINPAGE + '/product')
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'get product after creating with uncorrect product_data' do
      uncorrect_id = 7.times.map { StaticData::ALPHABET.sample }.join
      product_data = ProductFunctions.show_product(account,  uncorrect_id)
      expect(product_data.empty?).to be_falsey
      expect(product_data[:errors]).to eq([ErrorMessages::PRODUCT_NOT_FOUND])
    end

    it 'get product after creating' do
      new_product = ProductFunctions.create_new_product(account)
      new_product_data = http.request(new_product[0])
      product_id = JSON.parse(new_product_data.body)['product']['id']
      product_data = ProductFunctions.show_product(account,  product_id)
      expect(product_data[:id]).to eq(product_id)
    end
  end
end