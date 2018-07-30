require 'net/http'
require 'json'
require_relative '../../spec/tests/test_management'
class ResultSetFunctions
  # @param [Hash] args must has :token and one of next hashes:
  # {result_set_name: 'str', run_id: int}  - create result_set with name = 'str' and belongs to run with id = int
  # {result_set_name: 'str', run_name: 'str', plan_id: int}  - create result_set with name = 'str', run with name = 'str'
  # and belongs to plan with id = int
  # {result_set_name: 'str', run_name: 'str', plan_name: 'str', product_id: int} - create result_set, run and plan
  # {result_set_name: 'str', run_name: 'str', plan_name: 'str', product_name: 'str'} - create result_set, run and plan
  def self.create_new_result_set(http, options = {})
    options[:name] ||= http.random_name
    response = http.post_request('/api/result_set_new', get_params(options))
    [AbstractResultSet.new(response), options[:name], response.code]
  end

  def self.create_new_result_set_and_parse(http, options = {})
    responce, result_set_name = create_new_result_set(http, options)
    [JSON.parse(responce.body), result_set_name]
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

  def self.get_result_sets(http, options = {})
    response = http.post_request('/api/result_sets', result_set_data: { run_id: options[:id] })
    [AbstractResultSetPack.new(response), options[:name], response.code]
  end

  def self.get_result_set(http, options = {})
    response = http.post_request('/api/result_set', result_set_data: { id: options[:id] })
    AbstractResultSet.new(response)
  end

  def self.delete_result_set(http, option = {})
    response = http.post_request('/api/result_set_delete', result_set_data: { id: option[:id] })
    [JSON.parse(response.body), response.code]
  end

  def self.update_result_set(http, options = {})
    http.post_request('/api/result_set_edit', result_set_data: { id: options[:id], result_set_name: options[:name] })
  end

  def self.get_result_sets_by_status(http, options = {})
    responce = http.post_request('/api/result_sets_by_status', options)
    AbstractResultSetPack.new(responce)
  end
end
