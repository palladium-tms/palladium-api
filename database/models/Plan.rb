class Plan < Sequel::Model
  many_to_one :product
  one_to_many :runs
  one_to_many :result_sets
  plugin :validation_helpers
  plugin :association_dependencies
  add_association_dependencies runs: :destroy
  self.raise_on_save_failure = false
  plugin :timestamps

  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def self.product_id_validation(plan, product_id)
    if product_id.nil?
      plan.errors.add('product_id', "product_id can't be nil")
      return plan
    elsif Product[id: product_id].nil?
      plan.errors.add('product_id', 'product_id is not belongs to any product')
      return plan
    end
    plan
  end

  def self.plan_id_validation(plan_id)
    if plan_id.nil?
      return { 'plan_id' => ["plan_id can't be nil"] }
    elsif Plan[id: plan_id].nil?
      return { 'plan_id' => ['plan_id is not belongs to any product'] }
    end
    []
  end

  def self.getting_product(data)
    if data['plan_data']['product_id'].nil?
      new_product = Product.new(name: data['plan_data']['product_name'])
      new_product.valid?
      if new_product.valid?
        Product.find_or_create(name: data['plan_data']['product_name'])
      else
        new_product
      end
    else
      Product[id: data['plan_data']['product_id']]
    end
  end

  def self.find_or_new(data, product_id)
    Plan.find(name: data, product_id: product_id) || Plan.new(name: data)
  end

  # @param [Hash] data
  # example: data = {'plan_data': {'product_id': id, 'name': name}} or {'plan_data': {'product_name': name, 'name': name}}
  # return responce = {product: {product_data}, plan: {plan_data}, errors:: {product_errors: {}, plan_errors: {}}}
  def self.create_new(data)
    return { plan: Plan[id: data['run_data']['plan_id']] } if plan_id_exist?(data)
    product_resp = create_product(data)
    if product_resp[:product].nil?
      { plan_errors: 'product creating error' }.merge(product_resp)
    else
      new_plan = Plan.find_or_new(data['plan_data']['name'], product_resp[:product].id)
      if new_plan.valid?
        new_plan.save
        product_resp[:product].add_plan(new_plan)
        { plan: new_plan }.merge(product_resp)
      else
        { plan_errors: new_plan.errors.full_messages }
      end
    end
  end

  def self.create_product(data)
    unless data['plan_data'].nil?
      unless data['plan_data']['product_id'].nil? && data['plan_data']['product_name'].nil?
        return Product.create_new(data['plan_data']['product_id'] || data['plan_data']['product_name'])
      end
    end
    return { product_errors: 'product id of name not found' }
  end

  def self.plan_id_exist?(data)
    return !data['run_data']['plan_id'].nil? unless data['run_data'].nil?
    false
  end

  # @param data [Hash] like {'plan_data' => {id: int, plan_name: str}}
  def self.edit(data)
    plan = Plan[id: data['plan_data']['id']]
    if plan.set(name: data['plan_data']['plan_name']).valid?
      if Plan[name: data['plan_data']['plan_name'], product_id: plan.product_id].nil?
        plan.update(name: data['plan_data']['plan_name'], updated_at: Time.now)
        plan
      else
        { plan_errors: ['plan name already used'] }
      end
    else
      { plan_errors: plan.errors.full_messages }
    end
  end

  def self.get_runs(*args)
    plan = Plan[id: args.first['plan_id']]
    begin
      [plan.runs, []]
    rescue StandardError
      [[], 'Run data is incorrect']
    end
  end

  def self.get_statistic(runs)
    ResultSet.where(run_id: runs.map(&:id)).group_and_count(:run_id, :status).map(&:values).group_by do |e|
      e[:run_id]
    end
  end

  def self.add_statictic(runs)
    statistic = get_statistic(runs)
    runs.map(&:values).map do |run|
      run.merge!(statistic: statistic[run[:id]] || [])
    end
  end

  # Getting statistic and save in database(usually, statistic is not saving)
  def self.archive(plan_id)
    plan = Plan.find(id: plan_id)
    plans = Product.add_statictic([plan])
    plans
  end
end
