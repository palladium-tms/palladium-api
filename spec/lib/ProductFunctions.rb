require 'net/http'
require 'json'
class ProductFunctions
  # @param [String] name name for product. Max size = 30 simbols. If it empty - will be generate
  # return array with request and product name [request, product_name]
  def self.create_new_product(http, product_name = nil)
    product_name ||= http.random_name
    response = http.post_request('/api/product_new',
                                 product_data: { name: product_name })
    [response, product_name]
  end

  # return hash which keys - id of product, values - is a hash {'name': 'product_name'}
  def self.get_all_products(http)
    http.post_request('/api/products')
  end

  # @param [Integer] id is a id of product for deleting
  # return hash which keys - id of product, values - is a hash {'name': 'product_name'}
  def self.delete_product(http, id)
    http.post_request('/api/product_delete', product_data: { id: id })
  end

  # @param [Hash] product_data like a {:id => product_id, :name => product_name}
  def self.update_product(http, product_id, product_name = nil)
    product_name ||= http.random_name
    http.post_request('/api/product_edit', product_data: { id: product_id, name: product_name })
  end

  # @param [Integer] id is a id of product for deleting
  def self.show_product(http, id)
    http.post_request('/api/product', product_data: { id: id })
  end
end
