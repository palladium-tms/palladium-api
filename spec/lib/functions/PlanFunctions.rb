# frozen_string_literal: true

require 'net/http'
require 'json'
require_relative '../Abstractions'
module PlanFunctions
  # @param options [Hash]
  # options must contain :product_id key
  # @example
  # create_new_plan({name: 'plan_name', product_id: 1})
  def create_new_plan(options)
    options[:name] ||= rand_plan_name
    plan_data = { name: options[:name] }.merge(options)
    response = @http.post_request('/api/plan_new', plan_data:)
    AbstractPlan.new(response)
  end

  def get_plans(options = {})
    response = @http.post_request('/api/plans', plan_data: options)
    AbstractPlanPack.new(response)
  end

  def get_plans_statistic(plan_ids_array)
    @http.post_request('/api/plans_statistic', plan_data: plan_ids_array)
  end

  def reformat_statistic(statistic)
    statistic_result = {}
    statistic.each do |value|
      statistic_result[value['status']] = value['count']
    end
    statistic_result
  end

  def show_plan(options = {})
    response = @http.post_request('/api/plan', plan_data: { id: options[:id] })
    AbstractPlan.new(response)
  end

  def delete_plan(options = {})
    @http.post_request('/api/plan_delete', plan_data: { id: options[:id] })
  end

  def update_plan(options = {})
    response = @http.post_request('/api/plan_edit', plan_data: { id: options[:id], plan_name: options[:plan_name] })
    AbstractPlan.new(response)
  end

  def archive_plan(option = {})
    response = @http.post_request('/api/plan_archive', plan_data: { id: option[:id] })
    AbstractPlan.new(response)
  end
end
