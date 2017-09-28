class Suite < Sequel::Model
  many_to_one :product
  one_to_many :cases
  plugin :validation_helpers
  plugin :association_dependencies
  add_association_dependencies cases: :destroy
  self.raise_on_save_failure = false
  plugin :timestamps

  def before_destroy
    super
    self
    plan_ids = Product[id: self.product_id].plans.map(&:id)
    Run.where(name: self.name, plan_id: plan_ids).each do |current_run|
      current_run.destroy
    end
  end
end
