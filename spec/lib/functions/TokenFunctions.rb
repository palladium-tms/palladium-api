# frozen_string_literal: true

require 'net/http'
require 'json'
require_relative '../Abstractions'
module TokenFunctions
  def create_new_api_token(name = Faker::Movies::StarWars.droid)
    response = @http.post_request('/api/token_new', token_data: { name: })
    AbstractToken.new(response)
  end

  def get_tokens
    response = @http.post_request('/api/tokens')
    AbstractTokenPack.new(response)
  end

  def delete_token(id)
    @http.post_request('/api/token_delete', token_data: { id: })
  end
end
