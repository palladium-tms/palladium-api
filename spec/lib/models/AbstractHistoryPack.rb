require 'json'
require_relative '../../tests/test_management'
class AbstractHistoryPack
  attr_accessor :histories
  def initialize(history_pack)
    @histories = []
    JSON.parse(history_pack.body)['history_data'].map do |history|
      @histories << AbstractHistory.new(history)
    end
  end
end