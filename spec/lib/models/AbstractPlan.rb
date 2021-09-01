# frozen_string_literal: true

require 'json'
require_relative '../../tests/test_management'
class AbstractPlan
  attr_accessor :id, :name, :product_id,
                :created_at, :updated_at, :is_archived, :statistic, :is_null,
                :plan_errors, :product, :response, :api_created

  def initialize(data)
    @response = data
    if data.instance_of?(Hash)
      parsed_plan = data['plan']
      parsed_data = data
    else
      parsed_data = JSON.parse(data.body)
      parsed_plan = parsed_data['plan']
      if parsed_data['plan'].nil?
        @is_null = true
        @plan_errors = parsed_data['plan_errors']
        @product = AbstractProduct.new(@response) if parsed_data['product'] || parsed_data['product_errors']
        return
      end
    end
    @id = parsed_plan['id']
    @name = parsed_plan['name']
    @product_id = parsed_plan['product_id']
    @created_at = parsed_plan['created_at']
    @updated_at = parsed_plan['updated_at']
    @is_archived = parsed_plan['is_archived']
    @statistic = parsed_plan['statistic']
    @api_created = parsed_plan['api_created']
    @product = AbstractProduct.new(@response) if parsed_data['product']
  end

  def like_a?(plan)
    plan.id == @id && plan.name == @name && plan.created_at == @created_at && plan.updated_at == @updated_at && plan.is_archived == @is_archived && plan.product_id == @product_id
  end
end
