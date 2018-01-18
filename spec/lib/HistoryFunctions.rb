require 'net/http'
require 'json'
class HistoryFunctions
  # @param [Hash] args must has :id with exist product id

  def self.case_history(http, options = {})
    http.post_request('/api/case_history', {case_data: {id: options}})
  end
end