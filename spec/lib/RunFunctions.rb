require 'net/http'
require 'json'
require_relative '../../spec/tests/test_management'
class RunFunctions
  # @param [Hash] args must has :plan_id with plan id, and can has run_name with name (or will be generate
  # random name). example: {:run_name => "string", :plan_id => int }
  # examples:
  # {token: token, plan_id: int, run_name: str} - creating RUN(run_name) for PLAN(plan_id)
  # {token: token, plan_name: str, product_id: int, run_name: str} - creating RUN(run_name) and PLAN(plan_name). run for plan
  # {token: token, plan_name: str, product_name: str, run_name: str} - creating RUN(run_name) and PLAN(plan_name) and PRODUCT(product_name)
  def self.create_new_run(http, options = {})
    options[:name] ||= http.random_name
    options[:plan_name] ||= http.random_name
    params = if options[:plan_id]
               { run_data: { plan_id: options[:plan_id], name: options[:name] } }
             elsif options[:product_id]
               { plan_data: { product_id: options[:product_id], name: options[:plan_name] }, run_data: { name: options[:name] } }
             else
               { plan_data: { product_name: options[:product_name], name: options[:plan_name] }, run_data: { name: options[:name] } }
             end
    responce = http.post_request('/api/run_new', params)
    [AbstractRun.new(responce), options[:name], responce.code]
  end

  def self.create_new_run_and_parse(http, options = {})
    responce, run_name = create_new_run(http, options)
    [JSON.parse(responce.body), run_name]
  end

  # @param [Hash] args must has :run_data[name] with plan name and run_data[plan_id] with plan id
  def self.get_runs(http, options = {})
    responce = http.post_request('/api/runs', run_data: { plan_id: options[:id] })
    [AbstractRunPack.new(responce), responce.code]
  end

  def self.get_runs_and_parse(http, options = {})
    JSON.parse(get_runs(http, options).body)
  end

  def self.get_run(http, options = {})
    responce = http.post_request('/api/run', run_data: { id: options[:id] })
    [AbstractRun.new(responce), responce.code]
  end

  # @param [Hash] args must has :run_data[name] with plan name and run_data[plan_id] with plan id
  def self.delete_run(http, options = {})
    responce = http.post_request('/api/run_delete', run_data: { id: options[:id] })
    [JSON.parse(responce.body)['run'], responce.code]
  end
end
