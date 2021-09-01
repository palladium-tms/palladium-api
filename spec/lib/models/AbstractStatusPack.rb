require 'json'
class AbstractStatusPack
  attr_accessor :statuses, :parsed_body

  def initialize(responce)
    @statuses = []
    @parsed_body = JSON.parse(responce.body)
    @parsed_body['statuses'].map do |status|
      @statuses << AbstractStatus.new('status' => status[1])
    end
  end

  def contain?(status)
    contain = false
    @statuses.each do |current_statuses|
      contain ||= status.like_a?(current_statuses)
    end
    contain
  end
end
