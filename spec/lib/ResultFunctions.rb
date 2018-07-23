require 'net/http'
require 'json'
class ResultFunctions
  # @param [Hash] args must has 'result_data[result_set_id_id]' with result_set id, and can has result_data[message] with hash of messages (or will be generate
  # random message). example: {"result_data[result_set_id_id]" => int, "result_data[message]" => hash }
  def self.create_new_result(http, options = {})
    response = http.post_request('/api/result_new', get_params(options))
    [AbstractResult.new(response), options[:name], response.code]
  end

  def self.get_params(param)
    params = { result_set_data: {}, run_data: {}, plan_data: {}, result_data: {} }
    params[:result_data][:name] = param[:result_set_name] if param[:result_set_name]
    params[:result_set_data][:run_id] = param[:run_id] if param[:run_id]
    params[:result_set_data][:case_id] = param[:case_id] if param[:case_id]

    params[:run_data][:name] = param[:run_name] if param[:run_name]
    params[:run_data][:plan_id] = param[:plan_id] if param[:plan_id]

    params[:plan_data][:name] = param[:plan_name] if param[:plan_name]
    params[:plan_data][:product_id] = param[:product_id] if param[:product_id]

    params[:plan_data][:product_name] = param[:product_name] if param[:product_name]

    params[:result_data][:message] = param[:message] if param[:message]

    params[:result_data][:result_set_id] = param[:result_set_id] if param[:result_set_id]
    params[:result_set_data][:name] = param[:result_set_name] if param[:result_set_name]
    params[:result_data][:status] = param[:status]
    params
  end

  def self.create_new_result_and_parse(http, options = {})
    JSON.parse(ResultFunctions.create_new_result(http, options).body)
  end

  def self.get_results(http, options = {})
    response = http.post_request('/api/results', result_data: { result_set_id: options[:id] })
    AbstractResultPack.new(response)
  end

  def self.get_result(http, id)
    response = http.post_request('/api/result', result_data: { id: id })
    AbstractResult.new(response)
  end
end
