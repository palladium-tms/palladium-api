require 'json'
class AbstractProduct
  attr_accessor :id, :name, :created_at, :updated_at, :is_archived, :product_errors, :suite, :response

  def initialize(product_data = default_data)
    unless product_data.is_a?(Hash)
      @response = product_data
      body = JSON.parse(product_data.body)
      @product_errors = body['product_errors']
      product_data = body['product']
      @suite = AbstractSuite.new(@response) if body['suite']
    end
    return unless @product_errors.nil?

    @id = product_data['id']
    @name = product_data['name']
    @created_at = product_data['created_at']
    @updated_at = product_data['updated_at']
  end

  def default_data
    {
        'id': 0,
        'name': rand_product_name,
        'created_at': '0',
        'updated_at': '0'
    }
  end

  def like_a?(product)
    product.id == @id && product.name == @name && product.created_at == @created_at && product.updated_at == @updated_at && product.is_archived === @is_archived
  end
end
