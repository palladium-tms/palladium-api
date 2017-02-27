require 'rspec'
require 'net/http'
require 'json'
require_relative '../../data/static_data'
require_relative '../../lib/AuthFunctions'
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
      request = Net::HTTP::Post.new('/product_new', 'Content-Type' => 'application/json')
      corrent_product_name = 30.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({"user_data[email]": account[:email], "user_data[password]":  account[:password], "product_data[name]": corrent_product_name})
      http.request(request) # first creating
      response = http.request(request) # second creating
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].keys.count).to eq(1)
      expect(JSON.parse(response.body)['errors']['name']).to eq([ErrorMessages::NOT_UNIQ_PRODUCT_NAME])
      expect(JSON.parse(response.body)['product']['id'].nil?).to be_truthy
      expect(JSON.parse(response.body)['product']['name']).to eq(corrent_product_name)
    end




  end
end
