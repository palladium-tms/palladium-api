require 'net/http'
require 'json'
require_relative '../../spec/tests/test_management'
class HistoryFunctions
  # @param [Hash] args must has :id with exist product id

  def self.case_history(http, options = {})
    responce = http.post_request('/api/case_history', {case_data: {id: options}})
    AbstractHistoryPack.new(responce)
  end
end