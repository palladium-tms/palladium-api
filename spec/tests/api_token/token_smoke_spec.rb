require_relative '../test_management'
http = nil
describe 'Auth Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end

  describe 'create token' do
    it 'create new token' do
      token = TokenFunctions.create_new_api_token(http)
      expect(token.response.code).to eq('200')
      expect(token.token.size).to be > 10
      expect(token.name.size).to be > 10
    end
  end

  describe 'get all tokens' do
    it 'get all user tokens' do
      token_name = http.random_name
      TokenFunctions.create_new_api_token(http, token_name)
      token_pack = TokenFunctions.get_tokens(http)
      expect(token_pack.tokens.first.name).to eq(token_name)
      expect(token_pack.tokens.first.token.size).to be > 10
    end
  end

  describe 'use api token' do
    it 'Use api token for result_new method' do
      token = TokenFunctions.create_new_api_token(http)
      http_api = Http.new(token: token.token)

      product_name, plan_name, run_name, result_set_name, message = Array.new(5).map { http_api.random_name }
      result = ResultFunctions.create_new_result(http_api, plan_name: plan_name,
                                                             run_name: run_name,
                                                             product_name: product_name,
                                                             result_set_name: result_set_name,
                                                             message: message,
                                                             status: 'Passed')[0]
      expect(result.response.code).to eq('200')
    end

    it 'Use api token for products method' do
      token_obj = TokenFunctions.create_new_api_token(http)
      http_api = Http.new(token: token_obj.token)
      response = http_api.post_request('/api/products')
      expect(response.code).to eq('403')
    end

    it 'use deleted token' do
      token = TokenFunctions.create_new_api_token(http)
      http_api = Http.new(token: token.token)
      TokenFunctions.delete_token(http, token.id)

      product_name, plan_name, run_name, result_set_name, message = Array.new(5).map { http_api.random_name }
      params = ResultFunctions.get_params(plan_name: plan_name,
                                          run_name: run_name,
                                          product_name: product_name,
                                          result_set_name: result_set_name,
                                          message: message,
                                          status: 'Passed')
      response = http_api.post_request('/api/result_new', params)
      expect(response.code).to eq('403')
    end
  end

  describe 'delete token' do
    it 'delete token after create' do
      token = TokenFunctions.create_new_api_token(http)
      TokenFunctions.delete_token(http, token.id)
      token_pack = TokenFunctions.get_tokens(http)
      expect(token_pack.tokens).to be_empty
    end
  end
end
