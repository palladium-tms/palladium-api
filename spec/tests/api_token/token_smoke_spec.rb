require_relative '../test_management'
http = nil
describe 'Auth Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'create token' do
    it 'create new token' do
      response = TokenFunctions.create_new_api_token(http)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['token_data']['token'].size).to be > 10
      expect(JSON.parse(response.body)['token_data']['name'].size).to be > 10
    end
  end

  describe 'get all tokens' do
    it 'get all user tokens' do
      token_name = http.random_name
      TokenFunctions.create_new_api_token(http, token_name)
      response = TokenFunctions.get_tokens(http)
      expect(JSON.parse(response.body)['tokens'].first['name']).to eq(token_name)
      expect(JSON.parse(response.body)['tokens'].first['token'].size).to be > 10
    end
  end

  describe 'use api token' do
    it 'Use api token for result_new method' do
      token = JSON.parse(TokenFunctions.create_new_api_token(http).body)['token_data']['token']
      http_api = Http.new(token: token)

      product_name, plan_name, run_name, result_set_name, message = Array.new(5).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      response = ResultFunctions.create_new_result(http_api, plan_name: plan_name,
                                                             run_name: run_name,
                                                             product_name: product_name,
                                                             result_set_name: result_set_name,
                                                             message: message,
                                                             status: 'Passed')
      expect(response.code).to eq('200')
    end

    it 'Use api token for products method' do
      token = JSON.parse(TokenFunctions.create_new_api_token(http).body)['token_data']['token']
      http_api = Http.new(token: token)
      response = ProductFunctions.get_all_products(http_api)
      expect(response.code).to eq('403')
    end

    it 'use deleted token' do
      token = JSON.parse(TokenFunctions.create_new_api_token(http).body)['token_data']
      http_api = Http.new(token: token['token'])
      TokenFunctions.delete_token(http, token['id'])

      product_name, plan_name, run_name, result_set_name, message = Array.new(5).map { Array.new(30) { StaticData::ALPHABET.sample }.join }
      response = ResultFunctions.create_new_result(http_api, plan_name: plan_name,
                                                             run_name: run_name,
                                                             product_name: product_name,
                                                             result_set_name: result_set_name,
                                                             message: message,
                                                             status: 'Passed')
      expect(response.code).to eq('403')
    end
  end

  describe 'delete token' do
    it 'delete token after create' do
      token_id = JSON.parse(TokenFunctions.create_new_api_token(http).body)['token_data']['id']
      result = TokenFunctions.delete_token(http, token_id)
      tokens = TokenFunctions.get_tokens(http)
      expect(JSON.parse(result.body)['token']).to eq(token_id.to_s)
      expect(JSON.parse(tokens.body)['tokens']).to be_empty
    end
  end
end
