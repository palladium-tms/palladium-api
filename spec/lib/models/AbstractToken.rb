# frozen_string_literal: true

require 'json'
require_relative '../../tests/test_management'
class AbstractToken
  attr_accessor :id, :name, :token, :user_id, :errors, :response

  def initialize(data)
    @response = data
    data = JSON.parse(data.body)['token_data'] unless data.is_a?(Hash) || data.is_a?(Array)
    @id = data['id']
    @name = data['name']
    @token = data['token']
    @user_id = data['user_id']
  end
end
