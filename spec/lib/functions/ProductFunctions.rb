# frozen_string_literal: true

require 'net/http'
require 'json'
require_relative '../Abstractions'
module ProductFunctions
  def create_new_product(product_name = rand_product_name)
    response = @http.post_request('/api/product_new',
                                  product_data: { name: product_name })
    AbstractProduct.new(response)
  end

  # return hash which keys - id of product, values - is a hash {'name': 'product_name'}
  def get_all_products
    response = @http.post_request('/api/products')
    AbstractProductPack.new(response)
  end

  # @param [Integer] id is a id of product for deleting
  # return hash which keys - id of product, values - is a hash {'name': 'product_name'}
  def delete_product(id)
    @http.post_request('/api/product_delete', product_data: { id: })
  end

  def update_product(product_id, product_name)
    response = @http.post_request('/api/product_edit', product_data: { id: product_id, name: product_name })
    AbstractProduct.new(response)
  end

  # @param [Integer] id is a id of product for deleting
  def show_product(id)
    AbstractProduct.new(@http.post_request('/api/product', product_data: { id: }))
  end
end
