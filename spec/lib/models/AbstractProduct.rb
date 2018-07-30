require 'json'
class AbstractProduct
  attr_accessor :id, :name, :created_at, :updated_at, :is_archived, :product_errors, :suite

  def initialize(data)
    @product_errors = JSON.parse(data.body)['product_errors'] unless data.class == Hash
    return unless @product_errors.nil?
    parsed_product = if data.class == Hash
                       data['product']
                     else
                       JSON.parse(data.body)['product']
                     end
    @id = parsed_product['id']
    @name = parsed_product['name']
    @created_at = parsed_product['created_at']
    @updated_at = parsed_product['updated_at']
    @suite = AbstractSuite.new(data) if data['suite']
  end

  def like_a?(product)
    product.id == @id && product.name == @name && product.created_at == @created_at && product.updated_at == @updated_at && product.is_archived === @is_archived
  end
end
