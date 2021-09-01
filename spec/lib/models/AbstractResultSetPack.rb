# frozen_string_literal: true

require 'json'
class AbstractResultSetPack
  attr_accessor :result_sets, :parsed_body

  def initialize(result_set_pack)
    @result_sets = []
    unless result_set_pack.is_a?(Hash) || result_set_pack.is_a?(Array)
      @parsed_body = JSON.parse(result_set_pack.body)
      result_set_pack = @parsed_body['result_sets']
    end
    result_set_pack.map do |result_set|
      @result_sets << AbstractResultSet.new('result_sets' => [result_set])
    end
  end

  def contain?(result_set)
    contain = false
    @result_sets.each do |current_result_set|
      contain ||= result_set.like_a?(current_result_set)
    end
    contain
  end
end
