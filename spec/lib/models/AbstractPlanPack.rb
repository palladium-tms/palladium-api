require 'json'
class AbstractPlanPack
  attr_accessor :plans

  def initialize(plan_pack)
    @plans = []
    plans = JSON.parse(plan_pack.body)['plans']
    plans.map do |plan|
      @plans  << AbstractPlan.new('plan' => plan)
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