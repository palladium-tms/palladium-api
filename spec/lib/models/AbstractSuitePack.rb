require 'json'
require_relative '../../tests/test_management'
class AbstractSuitePack
  attr_accessor :suites

  def initialize(suite_pack)
    @suites = []
    suites = JSON.parse(suite_pack.body)['suites']
    suites.map do |suite|
      @suites << AbstractSuite.new('suite' => suite)
    end
  end
end