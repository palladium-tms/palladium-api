require 'json'
require_relative '../../tests/test_management'
class AbstractHistoryPack
  attr_accessor :histories

  def initialize(history_pack)
    @histories = []
    JSON.parse(history_pack.body)['result_sets_history'].map do |history|
      @histories << AbstractHistory.new(history)
    end
  end

  def get_oldest_by_plan
    oldest = @histories.first.plan_id
    @histories.each do |element|
      oldest = element.plan_id if element.plan_id < oldest
    end
    oldest
  end

  def get_youngest_by_plan
    youngest = @histories.first.plan_id
    @histories.each do |element|
      youngest = element.plan_id if element.plan_id > youngest
    end
    youngest
  end

  def plan_exist?(plan_id)
    @histories.each do |history|
      return true if history.plan_id == plan_id
    end
    false
  end

  def run_exist?(run_id)
    @histories.each do |history|
      return true if history.run_id == run_id
    end
    false
  end
end
