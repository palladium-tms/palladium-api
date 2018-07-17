require 'json'
require_relative '../../tests/test_management'
class AbstractResultSet
  attr_accessor :id, :name, :run_id, :created_at, :updated_at, :is_null, :run, :errors

  def initialize(data)
    if data.class == Hash
      parsed_result_set = data['result_sets'].first
    else
      data = JSON.parse(data.body)
      parsed_result_set = data['result_sets'].first
      if data['result_sets'].nil?
        @is_null = true
        @errors = data['result_sets']['errors'] if data['result_sets']['errors']
        return
      end
    end
    @id = parsed_result_set['id']
    @name = parsed_result_set['name']
    @run_id = parsed_result_set['run_id']
    @created_at = parsed_result_set['created_at']
    @updated_at = parsed_result_set['updated_at']
    @run = AbstractRun.new(data) if data['run']
  end

  def like_a?(result_set)
    result_set.id == @id && result_set.name == @name && result_set.created_at == @created_at && result_set.updated_at == @updated_at && result_set.run_id == @run_id
  end
end