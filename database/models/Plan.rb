class Plan < Sequel::Model
  many_to_one :product
  one_to_many :runs
  one_to_many :result_sets
  plugin :validation_helpers
  plugin :association_dependencies
  self.add_association_dependencies :runs => :destroy
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

  # @param [Hash] data
  # example: {'plan_data': {'product_id': id, 'name': name}} or {'plan_data': {'product_name': name, 'name': name}}
  def self.create_new(data)
    other_data = {} # product_id
    product = if data['plan_data']['product_id'].nil?
                Product.find_or_create(name: data['plan_data']['product_name'])
              else
                Product[id: data['plan_data']['product_id']]
              end
    other_data[:product_id] = product.id
    begin
      plan = Plan.find_or_create(name: data['plan_data']['name'], product_id: other_data[:product_id]) {|plan|
        plan.name = data['plan_data']['name']
      }
    rescue StandardError
      return self.product_id_validation(Plan.new(data['plan_data']), other_data[:product_id])
    end
    product.add_plan(plan)
  end

  # @param data [Hash] like {'plan_data' => {id: int, plan_name: str}}
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
    plan = Plan[:id => args.first['plan_id']]
    begin
      [plan.runs, []]
    rescue StandardError
      [[], 'Run data is incorrect']
    end
  end

  def self.get_statistic(runs)
    ResultSet.where(:run_id => runs.map(&:id)).group_and_count(:run_id, :status).map(&:values).group_by do |e|
      e[:run_id]
    end
  end

  def self.add_statictic(runs)
    statistic = get_statistic(runs)
    runs.map(&:values).map do |run|
      run.merge!({statistic: statistic[run[:id]] || []})
    end
  end

  # Method will created suites with name like run's, and cases with name like result_set's name
  def self.save_all_as_suites_and_cases(plan_id)
    Plan[id: plan_id].runs.select(:name)
  end
end