# frozen_string_literal: true

require 'json'
require_relative '../../tests/test_management'
class AbstractResultSet
  attr_accessor :id, :name, :run_id, :plan_id, :created_at, :updated_at, :is_null, :run, :errors, :response

  def initialize(data)
    @response = data
    if data.instance_of?(Hash)
    else
      data = JSON.parse(data.body)
      if data['result_sets'].nil?
        @is_null = true
        @errors = data['result_sets_errors'] if data['result_sets_errors']
        return
      end
    end
    parsed_result_set = data['result_sets'].first
    @id = parsed_result_set['id']
    @name = parsed_result_set['name']
    @run_id = parsed_result_set['run_id']
    @plan_id = parsed_result_set['plan_id']
    @created_at = parsed_result_set['created_at']
    @updated_at = parsed_result_set['updated_at']
    @run = AbstractRun.new(@response) if data['run']
  end

  def like_a?(result_set)
    result_set.id == @id && result_set.name == @name && result_set.created_at == @created_at && result_set.updated_at == @updated_at && result_set.run_id == @run_id
  end
end
