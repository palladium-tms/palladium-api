require 'json'
require_relative '../../tests/test_management'
class AbstractSuite
  attr_accessor :id, :name, :product_id, :created_at, :updated_at, :is_archived, :is_null, :case_errors, :product

  def initialize(data)
    if data.instance_of?(Hash)
      parsed_one_case = data['suite']
    else
      parsed_data = JSON.parse(data.body)
      parsed_one_case = parsed_data['suite']
    end
    @id = parsed_one_case['id']
    @name = parsed_one_case['name']
    @product_id = parsed_one_case['product_id']
    @created_at = parsed_one_case['created_at']
    @updated_at = parsed_one_case['updated_at']
  end

  def like_a?(one_case)
    one_case.id == @id && one_case.name == @name && one_case.created_at == @created_at && one_case.updated_at == @updated_at && one_case.product_id == @product_id
  end
end
