require 'net/http'
require 'json'
module SuiteFunctions
  def get_suites(options = {})
    response = @http.post_request('/api/suites', suite_data: { product_id: options[:id] })
    AbstractSuitePack.new(response)
  end

  def delete_suite(options = {})
    @http.post_request('/api/suite_delete', suite_data: { id: options[:id] })
  end

  def update_suite(options = {})
    response = @http.post_request('/api/suite_edit', suite_data: { name: options[:name], id: options[:id] })
    AbstractSuite.new(response)
  end
end
