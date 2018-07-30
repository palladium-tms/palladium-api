require 'json'
require_relative '../../tests/test_management'
class AbstractHistory
  attr_accessor :plan_id, :plan_name, :run_id, :status, :results, :statistic

  def initialize(data)
    @plan_id = data['plan_id']
    @plan_name = data['plan_name']
    @run_id = data['run_id']
    @status = data['status']
    @statistic = data['statistic']
    @results = data['results']
  end
end