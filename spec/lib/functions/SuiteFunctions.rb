# frozen_string_literal: true

require 'net/http'
require 'json'
module SuiteFunctions
  def get_suites(options = {})
    response = @http.post_request('/api/suites', suite_data: { product_id: options[:id] })
    AbstractSuitePack.new(response)
  end

  def delete_suite(suite_id:, plan_id:)
    @http.post_request('/api/suite_delete', suite_data: { id: suite_id, plan_id: plan_id })
  end

  def update_suite(options = {})
    response = @http.post_request('/api/suite_edit', suite_data: { name: options[:name], id: options[:id] })
    AbstractSuite.new(response)
  end
end
