require 'net/http'
require 'json'
class PlanFunctions

  # @param [Hash] args must has :plan_data[name] with plan name and plan_data[product_id] with product id
  def self.create_new_plan(http, options = {})
    options[:name] ||= http.random_name
    plan_data = {name: options[:name]}.merge(options)
    [http.post_request('/api/plan_new', {plan_data: plan_data}), options[:name] ]
  end

  # @param [Hash] args must has :product_id with product_id or :product_name with product name
  def self.get_plans(http, options = {})
    http.post_request('/api/plans', name_or_id(options))
  end

  def self.show_plan(http, options = {})
    http.post_request('/api/plan',  {plan_data: {id: options[:id]}})
  end

  # @param [Hash] args must has :plan_id[id] with plan id for deleting
  def self.delete_plan(http, options = {})
    http.post_request('/api/plan_delete', { plan_data: {id: options[:id]}})
  end

  def self.update_plan(http, options = {})
    http.post_request('/api/plan_edit', { plan_data: {id: options[:id], plan_name: options[:plan_name]}})
  end

  def self.name_or_id(params)
    if params[:product_id]
      {plan_data: {product_id: params[:product_id]}}
    else
      {plan_data: {product_name: params[:product_name]}}
    end
  end
end