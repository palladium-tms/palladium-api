class Run < Sequel::Model
  many_to_one :plan
  one_to_many :result_sets
  plugin :validation_helpers
  plugin :association_dependencies
  self.add_association_dependencies :result_sets => :nullify
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def self.plan_id_validation(run, plan_id)
    case
      when plan_id.nil?
        run.errors.add('plan_id', "plan_id can't be nil")
        return run
      when Plan[id: plan_id].nil?
        run.errors.add('plan_id', "plan_id is not belongs to any product")
        return run
    end
    run
  end

  def self.run_id_validation(run_id)
    case
      when run_id.nil?
        return {'run_id' => ["run_id can't be nil"]}
      when run_id.empty?
        return {'run_id' => ["run_id can't be empty"]}
      when Run[id: run_id].nil?
        return {'run_id' => ["run_id is not belongs to any plans"]}
      else
        {}
    end
  end

  def self.create_new(data)
    other_data = {}
    plan = if data['run_data']['plan_id'].nil?
             Plan.create_new(data)
           else
             Plan[id: data['run_data']['plan_id']]
           end
    other_data[:plan_id] = plan.id
    other_data.merge!({product_id: plan.product_id})
    begin
      run = Run.find_or_create(name: data['run_data']['name'], plan_id: other_data[:plan_id]) {|run|
        run.name = data['run_data']['name']
      }
    rescue StandardError
      return self.plan_id_validation(Plan.new(data['plan_data']), other_data[:plan_id])
    end
    other_data = suite_detected(plan, run, other_data)
    [plan.add_run(run), other_data]
  end

  def self.suite_detected(plan, run, other_data)
    if Suite.find(product_id: plan.product_id, name: run.name).nil?
      suite = Suite.create(name: run.name)
      Product[id: plan.product_id].add_suite(suite)
      other_data[:suite_id] = suite.id
    end
    other_data
  end

  def self.edit(data)
    begin
      run = Run[:id => data['run_data']['id']]
      run.update(:name => data['run_data']['run_name'], :updated_at => Time.now)
      run.valid?
      {'run_data': run.values, 'errors': run.errors}
    rescue StandardError
      {'run_data': Run.new.values, 'errors': [params: 'Run data is incorrect FIXME!!']} # FIXME: add validate
    end
  end

  def self.get_result_sets(*args)
    run = Run[:id => args.first['run_id']]
    begin
      [run.result_sets, []]
    rescue StandardError
      [[], 'Result_set data is incorrect']
    end
  end
end