# frozen_string_literal: true

require 'json'
class AbstractRunPack
  attr_accessor :runs

  def initialize(run_pack)
    @runs = []
    runs = JSON.parse(run_pack.body)['runs']
    runs.map do |run|
      @runs << AbstractRun.new('run' => run)
    end
  end

  # def diff(product_pack)
  #   self_ids = @products.map { |product| product.id}
  #   other_ids = product_pack.products.map { |product| product.id}
  #   self_ids - other_ids | other_ids - other_ids
  # end
  #
  # def get_product_by_id(id)
  #   @products.detect { |product| product.id == id}
  # end
end
