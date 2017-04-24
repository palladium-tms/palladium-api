class Plan < Sequel::Model
  many_to_one :product
  one_to_many :runs
  plugin :validation_helpers
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def self.product_id_validation(plan, product_id)
    case
      when product_id.nil?
        plan.errors.add('product_id', "product_id can't be nil")
        return plan
      when Product[id: product_id].nil?
        plan.errors.add('product_id', "product_id is not belongs to any product")
        return plan
    end
    plan
  end

  def self.plan_id_validation(plan_id)
    case
      when plan_id.nil?
        return {'plan_id' => ["plan_id can't be nil"]}
      when plan_id.empty?
        return {'plan_id' => ["plan_id can't be empty"]}
      when Plan[id: plan_id].nil?
        return {'plan_id' => ["plan_id is not belongs to any product"]}
    end
    []
  end

  def before_destroy
    super
    self.remove_all_runs
  end

  def self.create_new(data)
    data['plan_data']['product_id'] ||= Product.create_new(data).id
    err_plan = nil
    new_plan = Plan.find_or_create(name: data['plan_data']['name'], product_id: data['plan_data']['product_id']){|plan|
      plan.name = data['plan_data']['name']
      err_plan = plan unless plan.valid?
    }
    return err_plan unless err_plan.nil?
    plan = self.product_id_validation(new_plan, data['plan_data']['product_id'])
    if plan.errors.empty?
      plan.save
      Product[id: data['plan_data']['product_id']].add_plan(plan)
    end
    plan
  end
end