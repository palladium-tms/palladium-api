require 'net/http'
require 'json'
require_relative '../Abstractions'
module PlanFunctions
  def create_new_plan(options = {})
    options[:name] ||= rand_plan_name
    plan_data = { name: options[:name] }.merge(options)
    response = @http.post_request('/api/plan_new', plan_data: plan_data)
    AbstractPlan.new(response)
  end

  def get_plans(options = {})
    response = @http.post_request('/api/plans', PlanFunctions.name_or_id(options))
    AbstractPlanPack.new(response)
  end

  def show_plan(options = {})
    response = @http.post_request('/api/plan', plan_data: { id: options[:id] })
    AbstractPlan.new(response)
  end

  def delete_plan( options = {})
    @http.post_request('/api/plan_delete', plan_data: { id: options[:id] })
  end

  def update_plan(options = {})
    response = @http.post_request('/api/plan_edit', plan_data: { id: options[:id], plan_name: options[:plan_name] })
    AbstractPlan.new(response)
  end

  def self.name_or_id(params)
    if params[:product_id]
      { plan_data: { product_id: params[:product_id] } }
    else
      { plan_data: { product_name: params[:product_name] } }
    end
  end

  def self.archive_plan(http, id)
    response = http.post_request('/api/plan_archive', plan_data: { id: id })
    [AbstractPlan.new(response), response.code]
  end
end
