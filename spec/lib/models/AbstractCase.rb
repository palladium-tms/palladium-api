require 'json'
require_relative '../../tests/test_management'
class AbstractCase
  attr_accessor :id, :name, :product_id, :created_at, :updated_at, :is_archived, :is_null, :case_errors, :product, :response

  def initialize(data)
    if data.class == Hash
      parsed_one_case = data['case'].first
      parsed_data = data
    else
      @response = data
      parsed_data = JSON.parse(data.body)
      parsed_one_case = parsed_data['case']
    end
    @id = parsed_one_case['id']
    @name = parsed_one_case['name']
    @suite_id = parsed_one_case['suite_id']
    @created_at = parsed_one_case['created_at']
    @updated_at = parsed_one_case['updated_at']
    @is_archived = parsed_one_case['is_archived']
    @suite = AbstractSuite.new(parsed_data) if parsed_data['suite']
  end

  def like_a?(one_case)
    one_case.id == @id && one_case.name == @name && one_case.created_at == @created_at && one_case.updated_at == @updated_at && one_case.is_archived == @is_archived && one_case.product_id == @product_id
  end
end
