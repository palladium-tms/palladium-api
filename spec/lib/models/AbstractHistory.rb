require 'json'
require_relative '../../tests/test_management'
class AbstractHistory < AbstractResultSet
  attr_accessor :plan

  def initialize(data)
    super('result_sets' => [data])
    @plan = data['plan']
  end
end
