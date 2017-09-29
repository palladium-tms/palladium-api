require 'net/http'
require 'json'
class SuiteFunctions
  # @param [Hash] args must has :id with exist product id

  def self.get_suites(http, options = {})
    http.post_request('/api/suites',{"suite_data[product_id]": options[:id]})
  end


  def self.delete_suite(http, options = {})
    http.post_request('/api/suite_delete',{"suite_data[id]": options[:id]})
  end

  def self.get_suites_and_parse(http, options = {})
    responce = self.get_suites(http, options)
    JSON.parse(responce.body)['suites']
  end

  def self.update_suite(http, options = {})
    http.post_request('/api/suite_edit',{"suite_data[name]": options[:name], "suite_data[id]": options[:id]})
  end
end