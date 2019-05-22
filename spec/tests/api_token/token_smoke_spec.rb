require_relative '../test_management'
describe 'Auth Smoke' do
  before :each do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'create token' do
    it 'create new token' do
      token = @user.create_new_api_token
      expect(token.response.code).to eq('200')
      expect(token.token.size).to be > 10
      expect(token.name.size).to be > 1
    end
  end

  describe 'get all tokens' do
    it 'get all user tokens' do
      token_name = Faker::Movies::StarWars.droid
      @user.create_new_api_token(token_name)
      token_pack = @user.get_tokens
      expect(token_pack.tokens.first.name).to eq(token_name)
      expect(token_pack.tokens.first.token.size).to be > 10
    end
  end

  describe 'use api token' do
    let (:rand_word){ Faker::TvShows::Buffy.celebrity }
    it 'Use api token for result_new method' do
      token = @user.create_new_api_token
      @user_2 = AccountFunctions.create_and_parse
      @user_2.token = token.token
      result = @user_2.create_new_result(plan_name: rand_word,
                                         run_name: rand_word,
                                         product_name: rand_word,
                                         result_set_name: rand_word,
                                         message: rand_word,
                                         status: 'Passed')
      expect(result.response.code).to eq('200')
    end

    it 'Use api token for products method' do
      token = @user.create_new_api_token
      @user_2 = AccountFunctions.create_and_parse
      @user_2.token = token.token
      response = @user_2.post_request('/api/products')
      expect(response.code).to eq('403')
    end

    it 'use deleted token' do
      token = @user.create_new_api_token
      @user_2 = AccountFunctions.create_and_parse
      @user_2.token = token.token
      @user.delete_token(token.id)

      result = @user_2.create_new_result(plan_name: rand_word,
                                         run_name: rand_word,
                                         product_name: rand_word,
                                         result_set_name: rand_word,
                                         message: rand_word,
                                         status: 'Passed')
      expect(result.response.code).to eq('403')
    end
  end

  describe 'delete token' do
    it 'delete token after create' do
      token = @user.create_new_api_token
      @user.delete_token(token.id)
      token_pack = @user.get_tokens
      expect(token_pack.tokens).to be_empty
    end
  end
end
