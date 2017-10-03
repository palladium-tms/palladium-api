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
    plan_ids = Product[id: product_id].plans.map(&:id)
    Run.where(name: name, plan_id: plan_ids).each(&:destroy)
  end

  def self.edit(suite_data)
    suite = Suite[id: suite_data['id']]
    plan_ids = Product[id: suite.product_id].plans.map(&:id)
    time_for_update = Time.now
    Run.where(name: suite.name, plan_id: plan_ids).each do |current_run|
      current_run.update(name: suite_data['name'], updated_at: time_for_update)
    end
    suite.update(name: suite_data['name'], updated_at: time_for_update)
  end
end
