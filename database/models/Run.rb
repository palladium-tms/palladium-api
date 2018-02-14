class Run < Sequel::Model
  many_to_one :plan
  one_to_many :result_sets
  plugin :validation_helpers
  plugin :association_dependencies
  self.raise_on_save_failure = false
  plugin :timestamps

  def before_destroy
    super
    result_sets
    ResultSet.where(run_id: id).each do |result_set|
      result_set.remove_all_results
      Plan[result_set.plan_id].remove_result_set(result_set)
      result_set.destroy
    end
  end

  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def self.plan_id_validation(run, plan_id)
    if plan_id.nil?
      run.errors.add('plan_id', "plan_id can't be nil")
      return run
    elsif Plan[id: plan_id].nil?
      run.errors.add('plan_id', 'plan_id is not belongs to any product')
      return run
    end
    run
  end

  def self.run_id_validation(run_id)
    if run_id.nil?
      { 'run_id' => ["run_id can't be nil"] }
    elsif Run[id: run_id].nil?
      { 'run_id' => ['run_id is not belongs to any plans'] }
    else
      {}
    end
  end

  def self.find_or_new(name, plan_id)
    Run.find(name: name, plan_id: plan_id) || Run.new(name: name)
  end

  def self.create_new(data)
    return { run: Run[id: data['result_set_data']['run_id']] } if run_id_exist?(data)
    objects = Plan.create_new(data)
    if objects[:product_errors] || objects[:plan_errors]
      { run_errors: 'product or plan creating error' }.merge(objects)
    else
      run_name = get_run_name(data)
      run = Run.find_or_new(run_name, objects[:plan].id)
      if run.valid?
        run.save
        suite = suite_detected(objects[:plan], run)
        objects[:plan].add_run(run)
        { run: run, suite: suite }.merge(objects)
      else
        { run_errors: run.errors.full_messages }
      end
    end
  end

  def self.run_id_exist?(data)
    return !data['result_set_data']['run_id'].nil? unless data['result_set_data'].nil?
    false
  end

  def self.case_id_exist?(data)
    return !data['result_set_data']['case_id'].nil? unless data['result_set_data'].nil?
    false
  end

  def self.get_run_name(data)
    if data['run_data']
      return data['run_data']['name'] if data['run_data']['name']
    end
    if data['result_set_data']
      return  Case[id: data['result_set_data']['case_id']].suite.name if data['result_set_data']['case_id']
    end
  end

  def self.get_name_by_suite_if_exist(result_set_data)
    return Case[result_set_data['case_id']].suite.name if result_set_data['case_id']
  end

  def self.suite_detected(plan, run) # FIXME: need optimize
    suite = Suite.find(product_id: plan.product_id, name: run.name)
    if suite.nil?
      suite = Suite.create(name: run.name)
      Product[id: plan.product_id].add_suite(suite)
    else
      suite
    end
  end

  # def self.edit(data)
  #   run = Run[id: data['run_data']['id']]
  #   run.update(name: data['run_data']['run_name'], updated_at: Time.now)
  #   run.valid?
  #   { 'run_data' => run.values, 'errors' => run.errors }
  # rescue StandardError
  #   { 'run_data' => Run.new.values, 'errors' => { params: 'Run data is incorrect FIXME!!' } } # FIXME: add validate
  # end

  def self.get_result_sets(*args)
    run = Run[id: args.first['run_id']]
    begin
      [run.result_sets, []]
    rescue StandardError
      [[], 'Result_set data is incorrect']
    end
  end
end
