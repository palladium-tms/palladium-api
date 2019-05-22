require 'net/http'
require 'json'
module ProductPosition

  def set_product_position(options = {})
    @http.post_request('/api/set_product_position', options)
  end
end
