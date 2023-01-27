# frozen_string_literal: true

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

  def get_cases_from_plan(plan_id:, run_id: nil, suite_id: nil)
    case_data = { plan_id: }
    if suite_id
      case_data[:suite_id] = suite_id
    else
      case_data[:run_id] = run_id
    end
    response = @http.post_request('/api/cases', case_data:)
    AbstractCasePack.new(response)
  end

  def delete_case(case_id:, plan_id:)
    http.post_request('/api/case_delete', case_data: { id: case_id, plan_id: })
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
