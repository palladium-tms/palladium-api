require 'net/http'
require 'json'
module CaseFunctions
  def get_cases(options = {})
    response = if options[:id]
                 @http.post_request('/api/cases', case_data: { suite_id: options[:id] })
               else
                 @http.post_request('/api/cases', case_data: { product_id: options[:product_id], run_id: options[:run_id] })
               end
    AbstractCasePack.new(response)
  end

  def delete_case(options = {})
    http.post_request('/api/case_delete', case_data: { id: options[:id] })
  end

  def update_case(options = {})
    response = if options[:id]
      http.post_request('/api/case_edit', case_data: { id: options[:id], name: options[:name] })
    else
      http.post_request('/api/case_edit', case_data: { result_set_id: options[:result_set_id], name: options[:name] })
               end
    AbstractCase.new(response)
  end
end
