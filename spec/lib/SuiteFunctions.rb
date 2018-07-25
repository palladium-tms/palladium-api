require 'net/http'
require 'json'
class SuiteFunctions
  # @param [Hash] args must has :id with exist product id

  def self.get_suites(http, options = {})
    response = http.post_request('/api/suites', suite_data: { product_id: options[:id] })
    AbstractSuitePack.new(response)
  end

  def self.delete_suite(http, options = {})
    http.post_request('/api/suite_delete', suite_data: { id: options[:id] })
  end

  def self.update_suite(http, options = {})
    responce = http.post_request('/api/suite_edit', suite_data: { name: options[:name], id: options[:id] })
    AbstractSuite.new(responce)
  end
end
