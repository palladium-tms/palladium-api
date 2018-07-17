require 'json'
class AbstractProduct
  attr_accessor :id, :name, :created_at, :updated_at, :is_archived, :product_errors

  def initialize(data)
    @product_errors = JSON.parse(data.body)['product_errors'] unless data.class == Hash
    if @product_errors
      return
    end
    data = JSON.parse(data.body)['product'] unless data.class == Hash
    @id = data['id']
    @name = data['name']
    @created_at = data['created_at']
    @updated_at = data['updated_at']
    @is_archived = data['is_archived']
  end

  def like_a?(product)
    product.id == @id && product.name == @name && product.created_at == @created_at && product.updated_at == @updated_at && product.is_archived === @is_archived
  end
end
