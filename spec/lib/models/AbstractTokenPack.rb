require 'json'
require_relative '../../tests/test_management'
class AbstractTokenPack
  attr_accessor :id, :tokens, :errors, :response

  def initialize(data)
    @response = data
    data = JSON.parse(data.body)['tokens']
    @tokens = data.map do |token|
      AbstractToken.new(token)
    end
  end
end