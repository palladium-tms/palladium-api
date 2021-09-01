require 'json'
require_relative '../../tests/test_management'
class AbstractResultPack
  attr_accessor :id, :name, :created_at, :results

  def initialize(result_pack)
    @results = []
    result_pack = JSON.parse(result_pack.body)['results'] unless result_pack.is_a?(Hash) || result_pack.is_a?(Array)
    result_pack.map do |result|
      @results << AbstractResult.new('result' => [result])
    end
  end
end