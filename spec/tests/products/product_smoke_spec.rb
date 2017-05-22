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

  describe 'Get all products' do
    it 'check getting all products' do
      products = ProductFunctions.get_all_products(StaticData::TOKEN)
      expect(JSON.parse(products).key?('products')).to be_truthy
    end

    it 'check getting all product after creating new product' do
      product_data = ProductFunctions.create_new_product(account)
      product = JSON.parse(http.request(product_data[0]).body)['product'] # second creating
      products = ProductFunctions.get_all_products(account)
      expect(products[product['id']]['name']).to eq(product_data[1])
    end

    it 'check getting all products if its empty' do
      products = ProductFunctions.get_all_products(account)
      products.keys.each do |current_product_id|
        request = ProductFunctions.delete_product(account, current_product_id)
        http.request(request)
      end
      products = ProductFunctions.get_all_products(account)
      expect(products.empty?).to be_truthy
    end
  end

  describe 'Delete product' do
    it 'check deleting product with uncorrect user_data' do
      email = 10.times.map { StaticData::ALPHABET.sample }.join
      password = 7.times.map { StaticData::ALPHABET.sample }.join
      uri = URI(StaticData::MAINPAGE + '/product_delete')
      uri.query = URI.encode_www_form({"user_data[email]": email, "user_data[password]":  password})
      req = Net::HTTP::Delete.new(uri)
      response = http.request(req)
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
      expect(response.code).to eq('201')
    end

    it 'check deleting product with uncorrect product_data' do
      uncorrect_product_id = 7.times.map { StaticData::ALPHABET.sample }.join
      uri = URI(StaticData::MAINPAGE + '/product_delete')
      uri.query = URI.encode_www_form({"user_data[email]": account[:email], "user_data[password]":  account[:password], "product_data[id]": uncorrect_product_id})
      req = Net::HTTP::Delete.new(uri)
      response = http.request(req)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['product']).to eq(uncorrect_product_id)
      expect(JSON.parse(response.body)['errors']['product_id']).to eq([ErrorMessages::PRODUCT_ID_WRONG])
    end

    it 'check deleting product after product create. Its not in all product list' do
      product = ProductFunctions.create_new_product(account)
      new_product_response = http.request(product[0])
      product_id_for_deleting = JSON.parse(new_product_response.body)['product']['id']
      request = ProductFunctions.delete_product(account, product_id_for_deleting)
      response = http.request(request)
      products = ProductFunctions.get_all_products(account)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['product']).to eq(product_id_for_deleting.to_s)
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(products.key?(product_id_for_deleting)).to be_falsey
    end

    it 'check deleting product after product create' do
      product = ProductFunctions.create_new_product(account)
      new_product_response = http.request(product[0])
      product_id_for_deleting = JSON.parse(new_product_response.body)['product']['id']
      request = ProductFunctions.delete_product(account, product_id_for_deleting)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['product']).to eq(product_id_for_deleting.to_s)
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
    end
  end

  describe 'Edit product' do
    it 'edit product after creating' do
      product = ProductFunctions.create_new_product(account)
      product_name_for_updating = 30.times.map { StaticData::ALPHABET.sample }.join
      new_product_data = http.request(product[0])
      product_data = {id: JSON.parse(new_product_data.body)['product']['id'], name: product_name_for_updating}
      request = ProductFunctions.update_product(account, product_data)
      response = http.request(request)
      products = ProductFunctions.get_all_products(account)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(products[JSON.parse(new_product_data.body)['product']['id']]['name']).to eq(product_name_for_updating)
    end

    it 'edit product without user_data' do
      product = ProductFunctions.create_new_product(account)
      product_name_for_updating = 30.times.map { StaticData::ALPHABET.sample }.join
      new_product_data = http.request(product[0])
      request = Net::HTTP::Post.new('/product_edit', 'Content-Type' => 'application/json')
      request.set_form_data({"product_data[id]": JSON.parse(new_product_data.body)['product']['id'], "product_data[name]": product_name_for_updating})
      response = http.request(request)
      products = ProductFunctions.get_all_products(account)
      expect(response.code).to eq('201')
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
      expect(products[JSON.parse(new_product_data.body)['product']['id']]['name']).not_to eq(product_name_for_updating)
    end

    it 'edit product with uncorrect user_data' do
      product = ProductFunctions.create_new_product(account)
      product_name_for_updating = 30.times.map { StaticData::ALPHABET.sample }.join
      email = 10.times.map { StaticData::ALPHABET.sample }.join
      password = 7.times.map { StaticData::ALPHABET.sample }.join
      new_product_data = http.request(product[0])
      fake_account = {email: email, password: password}
      product_data = {id: JSON.parse(new_product_data.body)['product']['id'],name: product_name_for_updating}
      request = ProductFunctions.update_product(fake_account, product_data)
      response = http.request(request)
      products = ProductFunctions.get_all_products(account)
      expect(response.code).to eq('201')
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
      expect(products[JSON.parse(new_product_data.body)['product']['id']]['name']).not_to eq(product_name_for_updating)
    end

    it 'edit product with uncorrect product_data | very big' do
      product = ProductFunctions.create_new_product(account)
      product_name_for_updating = 35.times.map { StaticData::ALPHABET.sample }.join
      new_product_data = http.request(product[0])
      product_data = {id: JSON.parse(new_product_data.body)['product']['id'],name: product_name_for_updating}
      request = ProductFunctions.update_product(account, product_data)
      response = http.request(request)
      products = ProductFunctions.get_all_products(account)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']['name']).to eq([ErrorMessages::UNCORRECT_PRODUCT_NAME])
      expect(products[JSON.parse(new_product_data.body)['product']['id']]['name']).not_to eq(product_name_for_updating)
    end

    it 'edit product with uncorrect product_data | not uniq' do
      product = ProductFunctions.create_new_product(account)
      new_product_data = http.request(product[0])
      product_data = {id: JSON.parse(new_product_data.body)['product']['id'],name: product[1]}
      request = ProductFunctions.update_product(account, product_data)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']['name']).to eq([ErrorMessages::NOT_UNIQ_PRODUCT_NAME])
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