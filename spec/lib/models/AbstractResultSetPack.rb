require 'json'
class AbstractResultSetPack
  attr_accessor :result_sets

  def initialize(result_set_pack)
    @result_sets = []
    result_set_pack = JSON.parse(result_set_pack.body)['result_sets'] unless result_set_pack.is_a?(Hash) || result_set_pack.is_a?(Array)
    result_set_pack.map do |result_set|
      @result_sets << AbstractResultSet.new('result_sets' => [ result_set ])
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