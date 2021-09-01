# frozen_string_literal: true

require 'json'
require_relative '../../tests/test_management'
class AbstractStatus
  attr_accessor :id, :name, :color, :is_null, :errors, :response, :block

  def initialize(data)
    @response = data
    @errors = []
    unless data.instance_of?(Hash)
      data = JSON.parse(data.body)
      if data['status'].nil?
        @is_null = true
        @errors = data['status_errors'] if data['status_errors']
        return
      end
    end
    parsed_status = data['status']
    @id = parsed_status['id']
    @name = parsed_status['name']
    @block = parsed_status['block']
    @color = parsed_status['color']
  end

  def like_a?(status)
    status.id == @id && status.name == @name && status.color == @color && status.block == @block
  end
end
