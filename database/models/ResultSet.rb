class ResultSet < Sequel::Model
  many_to_one :plan
  many_to_one :run
  many_to_many :results
  plugin :validation_helpers
  self.raise_on_save_failure = false
  plugin :timestamps

  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def self.run_id_validation(result_set, run_id)
    if run_id.nil?
      result_set.errors.add('run_id', "run_id can't be nil")
      return result_set
    elsif Run[id: run_id].nil?
      result_set.errors.add('run_id', 'run_id is not belongs to any plans')
      return result_set
    end
    result_set
  end

  def self.find_or_new(name, run_id)
    ResultSet.find(name: name, run_id: run_id) || ResultSet.new(name: name)
  end

  # ['result_set_data']['name'] can be array (if you set result by some result sets by manualy)
  def self.create_new(data)
    return { result_sets: ResultSet.wheare(id: data['result_data']['result_set_id']) } if result_set_id_exist?(data)
    objects = Run.create_new(data)
    if objects[:product_errors] || objects[:plan_errors] || objects[:run_errors]
      { result_sets_errors: 'product, plan or run creating error' }.merge(objects)
    else
      name = get_result_set_name(data)
      errors_stack = []
      [*name].map do |name|
        new_result_set = ResultSet.find_or_new(name, objects[:run].id)
        if new_result_set.valid?
          new_result_set.save
          if objects[:plan]
            objects[:plan].add_result_set(new_result_set)
          else
            objects[:run].plan.add_result_set(new_result_set)
          end
          objects[:run].add_result_set(new_result_set)
          case_detected(new_result_set.name, objects[:run])
          objects[:result_sets] = []
          objects[:result_sets] << new_result_set
        else
          errors_stack << new_result_set.errors.full_messages
        end
      end
      objects[:result_sets_errors] = errors_stack unless errors_stack.empty?
      objects
    end
  end

  def self.result_set_id_exist?(data)
    return !data['result_data']['result_set_id'].nil? if data['result_data']
    false
  end

  def self.case_detected(result_set_name, run)
    suite = Suite.find_or_create(product_id: Plan[id: run.plan_id].product_id, name: run.name) do |suite|
      suite.name = run.name
    end
    if suite.cases_dataset[name: result_set_name].nil?
      _case = Case.create(name: result_set_name)
      suite.add_case(_case)
    end
  end

  def self.get_result_set_name(data)
    if data['result_set_data']['case_id']
      Case[data['result_set_data']['case_id']].name
    elsif data['result_set_data']['name']
      data['result_set_data']['name']
    end
  end

  def self.edit(data)
    result_set = ResultSet[id: data['result_set_data']['id']]
    result_set.update(name: data['result_set_data']['result_set_name'], updated_at: Time.now)
    result_set.valid?
    { 'result_set_data' => result_set.values, 'errors' => result_set.errors }
  rescue StandardError
    { 'result_set_data' => ResultSet.new.values, 'errors' => [params: 'Run data is incorrect FIXME!!'] } # FIXME: add validate
  end

  def self.get_results(*args)
    result_set = ResultSet[id: args.first['result_set_id']]
    begin
      [result_set.results, []]
    rescue StandardError
      [[], 'Result data is incorrect']
    end
  end
end
