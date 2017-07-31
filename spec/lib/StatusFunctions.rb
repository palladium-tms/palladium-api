require 'net/http'
require 'json'
class StatusFunctions
  # @param [Hash] args must has 'result_data[result_set_id_id]' with result_set id, and can has result_data[message] with hash of messages (or will be generate
  # random message). example: {"result_data[result_set_id_id]" => int, "result_data[message]" => hash }
  def self.create_new_status(http, options = {})
    http.post_request('/api/status_new', params(options))
  end

  def self.get_all_statuses(http)
    http.post_request('/api/statuses')
  end

  def self.status_edit(http, options = {})
    http.post_request('/api/status_edit', params(options))
  end

  def self.params(param)
    params = {}
    params.merge!({'status_data[id]': param[:id]}) if param[:id]
    params.merge!({'status_data[name]': param[:name]}) if param[:name]
    params.merge!({'status_data[color]': param[:color]}) if param[:color]
    params.merge!({'status_data[block]': param[:block]}) unless param[:block].nil?
    params
  end
end