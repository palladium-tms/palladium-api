require 'json'
require_relative '../../tests/test_management'
class AbstractHistory
  attr_accessor :plan_id, :plan_name, :updated_at, :run_id, :status, :result_set_id, :statistic, :results

  def initialize(data)
    @plan_id = data['plan_id']
    @plan_name = data['plan_name']
    @updated_at = data['updated_at']
    @run_id = data['run_id']
    @status = data['status']
    @result_set_id = data['result_set_id']
    @status = data['status']
    @statistic = data['status']
    @results = data['results']
  end
end