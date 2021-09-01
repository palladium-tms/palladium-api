# frozen_string_literal: true

require 'json'
require_relative '../../tests/test_management'
class AbstractRun
  attr_accessor :id, :name, :plan_id, :created_at, :updated_at, :is_null, :plan, :errors, :response

  def initialize(data)
    @response = data
    if data.instance_of?(Hash)
      parsed_run = data['run']
    else
      data = JSON.parse(data.body)
      parsed_run = data['run']
      if data['run'].nil?
        @is_null = true
        return
      elsif data['run']['errors']
        @errors = data['run']['errors']
        return
      end
    end
    @id = parsed_run['id']
    @name = parsed_run['name']
    @plan_id = parsed_run['plan_id']
    @created_at = parsed_run['created_at']
    @updated_at = parsed_run['updated_at']
    @plan = AbstractPlan.new(@response) if data['plan']
  end

  def like_a?(run)
    run.id == @id && run.name == @name && run.created_at == @created_at && run.updated_at == @updated_at && run.plan_id == @plan_id
  end
end
