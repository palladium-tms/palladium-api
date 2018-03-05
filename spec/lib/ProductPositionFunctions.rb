require 'net/http'
require 'json'
class ProductPosition

  def self.set_product_position(http, options = {})
    http.post_request('/api/set_product_position', options)
  end
end
