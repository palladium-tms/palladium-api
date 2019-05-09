require 'json'
require_relative '../../tests/test_management'
class AbstractResult
  attr_accessor :id, :message, :status_id, :created_at, :updated_at, :is_null, :result_set, :errors, :response, :status

  def initialize(data)
    @response = data
    @is_null = false
    if data.class == Hash
      parsed_result = data['result'].first
    elsif data.body.empty?
      @is_null = true
      return
    else
      data = JSON.parse(data.body)
      if data['result'].nil?
        @is_null = true
        @errors = data['result_sets_errors'] if data['result_sets_errors']
        return
      end
      parsed_result = data['result']
    end
    @id = parsed_result['id']
    @message = parsed_result['message']
    @status_id = parsed_result['status_id']
    @created_at = parsed_result['created_at']
    @updated_at = parsed_result['updated_at']
    @status = AbstractStatus.new(data) if data['status']
    @result_set = data['result_sets'].size == 1 ? AbstractResultSet.new(@response) : AbstractResultSetPack.new(data['result_sets']) if data['result_sets']
  end

  def like_a?(result)
    result.id == @id && result.name == @name && result.created_at == @created_at && result.updated_at == @updated_at && result.run_id == @result_set_id
  end

  def run
    @result_set&.run
  end

  def plan
    run&.plan
  end

  def product
    plan&.product
  end
end