require 'net/http'
require 'json'
require_relative '../Abstractions'
module ResultSetFunctions
  def create_new_result_set(options = {})
    options[:name] ||= rand_result_set_name
    response = @http.post_request('/api/result_set_new', ResultSetFunctions.get_params(options))
    AbstractResultSet.new(response)
  end

  def self.get_params(param)
    params = { result_set_data: {}, run_data: {}, plan_data: {} }
    params[:result_set_data] = { name: param[:name] }
    params[:result_set_data][:run_id] = param[:run_id] if param[:run_id]
    params[:run_data] = { name: param[:run_name] } if param[:run_name]
    params[:run_data][:plan_id] = param[:plan_id] if param[:plan_id]

    params[:plan_data] = { name: param[:plan_name] } if param[:plan_name]
    params[:plan_data][:product_id] = param[:product_id] if param[:product_id]

    params[:plan_data][:product_name] = param[:product_name] if param[:product_name]
    params
  end

  def get_result_sets(options = {})
    response = @http.post_request('/api/result_sets', result_set_data: { run_id: options[:id] })
    AbstractResultSetPack.new(response)
  end

  def get_result_set(options = {})
    response = @http.post_request('/api/result_set', result_set_data: { id: options[:id] })
    AbstractResultSet.new(response)
  end

  def delete_result_set(option = {})
    @http.post_request('/api/result_set_delete', result_set_data: { id: option[:id] })
  end

  def self.update_result_set(http, options = {})
    http.post_request('/api/result_set_edit', result_set_data: { id: options[:id], result_set_name: options[:name] })
  end

  def get_result_sets_by_status(options = {})
    response = @http.post_request('/api/result_sets_by_status', options)
    AbstractResultSetPack.new(response)
  end
end
