require 'json'
require_relative '../../tests/test_management'
class AbstractHistoryPack
  attr_accessor :histories

  def initialize(data)
    parsed_data = JSON.parse(data.body)['history_data']
    @histories = []
    parsed_data.each do |data|
      @histories << AbstractHistory.new(data)
    end
  end
end