require 'net/http'
require 'json'
require_relative '../Abstractions'
module RunFunctions
  # @param [Hash] options must contain plan_id or plan_name and product_id
  # :name is optional, and it will be generated it not exist
  # @example:
  # option = {name: 'run_name', :plan_id: 123}
  def create_new_run(options = {})
    options[:name] ||= rand_run_name
    params = if options[:plan_id]
               { run_data: { plan_id: options[:plan_id], name: options[:name] } }
             elsif options[:product_id]
               { plan_data: { product_id: options[:product_id], name: options[:plan_name] }, run_data: { name: options[:name] } }
             else
               { plan_data: { product_name: options[:product_name], name: options[:plan_name] }, run_data: { name: options[:name] } }
             end
    response = @http.post_request('/api/run_new', params)
    AbstractRun.new(response)
  end

  def get_runs(plan_id:)
    response = http.post_request('/api/runs', run_data: { plan_id: plan_id })
    [AbstractRunPack.new(response), AbstractSuitePack.new(response)]
  end

  def get_run(options = {})
    response = @http.post_request('/api/run', run_data: { id: options[:id] })
    AbstractRun.new(response)
  end

  def delete_run(options = {})
    @http.post_request('/api/run_delete', run_data: { id: options[:id] })
  end
end
