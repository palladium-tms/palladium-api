class Plan < Sequel::Model
  many_to_one :product
  one_to_many :runs
  plugin :validation_helpers
  plugin :association_dependencies
  self.add_association_dependencies :runs=>:destroy
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


  # @param [Hash] data
  # example: {'plan_data': {'product_id': id, 'name': name}} or {'plan_data': {'product_name': name, 'name': name}}
  def self.create_new(data)
    data['plan_data']['product_id'] ||= Product.find_or_create(name: data['plan_data']['product_name']).id
    begin
      plan = Plan.find_or_create(name: data['plan_data']['name'], product_id: data['plan_data']['product_id']) {|plan|
        plan.name = data['plan_data']['name']
      }
    rescue StandardError
      return self.product_id_validation(Plan.new(data['plan_data']), data['plan_data']['product_id'])
    end
    Product[id: data['plan_data']['product_id']].add_plan(plan)
  end

  def self.edit(data)
    begin
      plan = Plan[:id => data['plan_data']['id']]
      plan.update(:name => data['plan_data']['plan_name'], :updated_at => Time.now)
      plan.valid?
      {'plan_data': plan.values, 'errors': plan.errors}
    rescue StandardError
      {'plan_data': Plan.new.values, 'errors': [params: 'Plan data is incorrect FIXME!!']} # FIXME: add validate
    end
  end

  def self.get_runs(*args)
    plan =  Plan[:id => args.first['plan_id']]
    begin
      [plan.runs, []]
    rescue StandardError
      [[], 'Run data is incorrect']
    end
  end
end