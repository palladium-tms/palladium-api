require 'net/http'
require 'json'
class CaseFunctions
  # @param [Hash] args must has :id with exist product id

  def self.get_cases(http, options = {})
    http.post_request('/api/cases',{"case_data[suite_id]": options[:id]})
  end


  def self.delete_case(http, options = {})
    http.post_request('/api/case_delete',{"case_data[id]": options[:id]})
  end
end