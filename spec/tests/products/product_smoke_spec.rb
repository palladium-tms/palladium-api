require 'rspec'
require 'net/http'
require 'json'
require_relative '../../data/static_data'
require_relative '../../lib/AuthFunctions'
require_relative '../../lib/ProductFunctions'
http = nil
account = nil
describe 'Smoke' do
  before :all do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    request = AuthFunctions.create_new_account
    http.request(request[0])
    account = request[1]
  end
  describe 'Create new product' do
    it 'check creating new product without user_data' do
      request = Net::HTTP::Post.new('/product_new', 'Content-Type' => 'application/json')
      product_name = 31.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({"product[name]": product_name})
      response = http.request(request)
      expect(response.code).to eq('201')
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'check creating new product with uncorrect user_data' do
      request = Net::HTTP::Post.new('/product_new', 'Content-Type' => 'application/json')
      product_name = 31.times.map { StaticData::ALPHABET.sample }.join
      email = 10.times.map { StaticData::ALPHABET.sample }.join + '@g.com'
      password = 7.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({"user_data[email]": email, "user_data[password]": password, "product[name]": product_name})
      response = http.request(request)
      expect(response.code).to eq('201')
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'check creating new product with correct user_data and uncorrect product_data' do
      request = Net::HTTP::Post.new('/product_new', 'Content-Type' => 'application/json')
      uncorrent_product_name = 31.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({"user_data[email]": account[:email], "user_data[password]":  account[:password], "product_data[name]": uncorrent_product_name})
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].keys.count).to eq(1)
      expect(JSON.parse(response.body)['product']['id'].nil?).to be_truthy
      expect(JSON.parse(response.body)['errors']['name']).to eq([ErrorMessages::UNCORRECT_PRODUCT_NAME])
    end

    it 'check creating new product with correct user_data and correct product_data' do
      request = Net::HTTP::Post.new('/product_new', 'Content-Type' => 'application/json')
      corrent_product_name = 30.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({"user_data[email]": account[:email], "user_data[password]":  account[:password], "product_data[name]": corrent_product_name})
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['product']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['product']['name']).to eq(corrent_product_name)
    end

    it 'check creating new product with correct user_data and exists correct product_data' do
      product = ProductFunctions.create_new_product(account)
      http.request(product[0]) # first creating
      response = http.request(product[0]) # second creating
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].keys.count).to eq(1)
      expect(JSON.parse(response.body)['errors']['name']).to eq([ErrorMessages::NOT_UNIQ_PRODUCT_NAME])
      expect(JSON.parse(response.body)['product']['id'].nil?).to be_truthy
      expect(JSON.parse(response.body)['product']['name']).to eq(product[1])
    end
  end

  describe 'Get all products' do
    it 'check getting all product with uncorrect user_data' do
      email = 10.times.map { StaticData::ALPHABET.sample }.join
      password = 7.times.map { StaticData::ALPHABET.sample }.join
      uri = URI(StaticData::MAINPAGE + '/products')
      params = {"user_data[email]": email, "user_data[password]":  password}
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
      expect(response.code).to eq('201')
    end

    it 'check getting all product after creating new product' do
      product_data = ProductFunctions.create_new_product(account)
      product = JSON.parse(http.request(product_data[0]).body)['product'] # second creating
      products = ProductFunctions.get_all_products(account)
      expect(products[product['id']]['name']).to eq(product_data[1])
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
      expect(JSON.parse(response.body)['product_deleted']).to be_falsey
    end

    it 'check deleting product after product create' do
      product = ProductFunctions.create_new_product(account)
      new_product_response = http.request(product[0])
      product_id_for_deleting = JSON.parse(new_product_response.body)['product']['id']
      request = ProductFunctions.delete_product(account, product_id_for_deleting)
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['product']).to eq(product_id_for_deleting.to_s)
      expect(JSON.parse(response.body)['product_deleted']).to be_truthy
    end
  end
end
#TODO: add tests for check product after deliting in "all_products" list