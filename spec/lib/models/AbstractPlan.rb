require 'json'
require_relative '../../tests/test_management'
class AbstractPlan
  attr_accessor :id, :name, :product_id, :created_at, :updated_at, :is_archived

  def initialize(data)
    parsed_data = JSON.parse(data.body)
    parsed_plan = parsed_data['plan']
    @id = parsed_plan['id']
    @name = parsed_plan['name']
    @product_id = parsed_plan['product_id']
    @created_at = parsed_plan['created_at']
    @updated_at = parsed_plan['updated_at']
    @is_archived = parsed_plan['is_archived']
    @product = AbstractProduct.new(data) if parsed_plan['product']
  end
end