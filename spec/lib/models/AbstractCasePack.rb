require 'json'
require_relative '../../tests/test_management'
class AbstractCasePack
  attr_accessor :id, :name, :created_at, :suite, :cases
  def initialize(case_pack)
    @cases = []
    case_pack = JSON.parse(case_pack.body)['cases'] unless case_pack.is_a?(Hash) || case_pack.is_a?(Array)
    case_pack.map do |one_case|
      @cases << AbstractCase.new('case' => [one_case])
    end
  end
end