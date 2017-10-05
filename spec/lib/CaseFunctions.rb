require 'net/http'
require 'json'
class CaseFunctions
  # @param [Hash] args must has :id with exist product id

  def self.get_cases(http, options = {})
    if options[:id]
      http.post_request('/api/cases',{"case_data[suite_id]": options[:id]})
    else
      http.post_request('/api/cases',{"case_data[run_id]": options[:run_id], "case_data[product_id]": options[:product_id]})
    end
  end

  def self.delete_case(http, options = {})
    http.post_request('/api/case_delete',{"case_data[id]": options[:id]})
  end

  def self.update_case(http, options = {})
    if options[:id]
      http.post_request('/api/case_edit',{"case_data[id]": options[:id], "case_data[name]": options[:name]})
    else
      http.post_request('/api/case_edit',{"case_data[result_set_id]": options[:result_set_id], "case_data[name]": options[:name]})
    end
  end
end