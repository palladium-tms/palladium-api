require 'net/http'
require 'json'
require_relative '../../spec/lib/ObjectWrap/http'
class TokenFunctions
  # @param [Strung] email for account. If it empty - will be generate
  # @param [String] password  for account. Min size = 6 simbols. If it empty - will be generate
  # return array with request and product name [request, product_name]
  def self.create_new_api_token(http, name = nil)
    name ||= http.random_name
    http.post_request('/api/token_new', {token_data: {name: name}})
  end

  def self.get_tokens(http)
    http.post_request('/api/tokens')
  end

  def self.delete_token(http, id)
    http.post_request('/api/token_delete', {token_data: {id: id}})
  end
end