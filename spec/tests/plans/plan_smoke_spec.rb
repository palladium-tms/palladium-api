require 'rspec'
require 'net/http'
require 'json'
require_relative '../../data/static_data'
require_relative '../../lib/AuthFunctions'
require_relative '../../lib/ProductFunctions'
require_relative '../../lib/PlanFunctions'
http = nil
account = nil
product_id = nil
describe 'Smoke' do
  before :all do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
    request = AuthFunctions.create_new_account
    http.request(request[0])
    account = request[1]
  end
  describe 'Create new plan' do
    before :each do
      product = ProductFunctions.create_new_product(account)
      product_id = JSON.parse(http.request(product[0]).body)['product']['id']
    end

    it 'check creating new plan' do
      request = PlanFunctions.create_new_plan({"user_data[email]": account[:email], "user_data[password]":  account[:password],
                                     "plan_data[product_id]": product_id})
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(response.body)['plan']['id'].nil?).to be_falsey
      expect(JSON.parse(response.body)['plan']['name']).to eq(request[1])
      expect(JSON.parse(response.body)['plan']['product_id']).to eq(product_id)
    end

    it 'check creating new plan without user_data' do
      request = Net::HTTP::Post.new('/plan_new', 'Content-Type' => 'application/json')
      plan_name = 30.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({"plan_data[name]": plan_name, "plan_data[product_id]": product_id})
      response = http.request(request)
      expect(response.code).to eq('201')
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'check creating new plan with uncorrect user_data' do
      request = Net::HTTP::Post.new('/plan_new', 'Content-Type' => 'application/json')
      plan_name = 30.times.map { StaticData::ALPHABET.sample }.join
      user_name = 30.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({"user_data[email]": user_name, "user_data[password]":  account[:password],
                             "plan_data[name]": plan_name, "plan_data[product_id]": product_id})
      response = http.request(request)
      expect(response.code).to eq('201')
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end

    it 'check creating new plan without plan_data' do
      request = Net::HTTP::Post.new('/plan_new', 'Content-Type' => 'application/json')
      request.set_form_data({"user_data[email]": account[:email], "user_data[password]":  account[:password]})
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']['name']).to eq([ErrorMessages::CANT_BE_EMPTY_PLAN_NAME])
      expect(JSON.parse(response.body)['errors']['product_id']).to eq([ErrorMessages::PRODUCT_ID_CANT_BE_NIL_PLAN_NAME])
      expect(JSON.parse(response.body)['plan'].nil?).to be_falsey
    end

    it 'check creating new plan without plan_data' do
      request = PlanFunctions.create_new_plan({"user_data[email]": account[:email],
                                               "user_data[password]":  account[:password]})
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']['product_id']).to eq([ErrorMessages::PRODUCT_ID_CANT_BE_NIL_PLAN_NAME])
    end

    it 'check creating new plan if plan_data[product_id] is empty' do
      request = PlanFunctions.create_new_plan({"user_data[email]": account[:email],
                                               "user_data[password]":  account[:password], "plan_data[product_id]": ''})
      response = http.request(request[0])
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['errors']['product_id']).to eq([ErrorMessages::PRODUCT_ID_CANT_BE_EMPTY_PLAN_NAME])
    end
  end
end