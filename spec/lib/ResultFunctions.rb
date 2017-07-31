require 'net/http'
require 'json'
class ResultFunctions
  # @param [Hash] args must has 'result_data[result_set_id_id]' with result_set id, and can has result_data[message] with hash of messages (or will be generate
  # random message). example: {"result_data[result_set_id_id]" => int, "result_data[message]" => hash }
  def self.create_new_result(http, options = {})
    http.post_request('/api/result_new', get_params(options).merge("result_data[status]": options[:status]))
  end

  def self.get_params(param)
    params = {}
    params.merge!('result_set_data[name]': param[:result_set_name]) if param[:result_set_name]
    params.merge!('result_set_data[run_id]': param[:run_id]) if param[:run_id]

    params.merge!('run_data[name]': param[:run_name]) if param[:run_name]
    params.merge!('run_data[plan_id]': param[:plan_id]) if param[:plan_id]

    params.merge!('plan_data[name]': param[:plan_name]) if param[:plan_name]
    params.merge!('plan_data[product_id]': param[:product_id]) if param[:product_id]

    params.merge!('plan_data[product_name]': param[:product_name]) if param[:product_name]

    params.merge!('result_data[message]': param[:message]) if param[:message]

    params.merge!('result_data[result_set_id][]': param[:result_set_id]) if param[:result_set_id]
    params
  end

  def self.get_results(http ,options = {})
    http.post_request('/api/results', {"result_data[result_set_id]": options[:id]})
  end
end