class ResultSet < Sequel::Model
  many_to_one :plan
  many_to_one :run
  many_to_many :results
  plugin :validation_helpers
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def self.run_id_validation(result_set, run_id)
    case
      when run_id.nil?
        result_set.errors.add('run_id', "run_id can't be nil")
        return result_set
      when Run[id: run_id].nil?
        result_set.errors.add('run_id', "run_id is not belongs to any plans")
        return result_set
    end
    result_set
  end

  def self.create_new(data)
    other_data = {}
    run = if data['result_set_data']['run_id'].nil?
            run, other_run_data = Run.create_new(data)
            other_data.merge!(other_run_data)
            run
          else
            Run[data['result_set_data']['run_id']]
          end
    other_data[:run_id] = run.id
    other_data[:plan_id] = run.plan_id
    data['result_set_data']['name'] = Case[data['result_set_data']['case_id']].name if data['result_set_data']['case_id']
    result_sets = [*data['result_set_data']['name']].map do |name|
      begin
        result_set = ResultSet.find_or_create(name: name, run_id: other_data[:run_id]) do |result_set|
          result_set.name = name
          result_set.plan_id = other_data[:plan_id]
        end
        Plan[id: other_data[:plan_id]].add_result_set(result_set)
      rescue StandardError
        return self.run_id_validation(Run.new(data['result_set_data']), other_data[:plan_id])
      end
      self.case_detected(result_set.name, run)
      run.add_result_set(result_set)
    end
    [result_sets, other_data]
  end

  def self.case_detected(result_set_name, run)
    suite = Suite.find_or_create(product_id: Plan[id: run.plan_id].product_id, name: run.name) {|suite|
      suite.name = run.name
    }
    if suite.cases_dataset[name: result_set_name].nil?
      _case = Case.create(name: result_set_name)
      suite.add_case(_case)
    end
  end

  def self.edit(data)
    begin
      result_set = ResultSet[:id => data['result_set_data']['id']]
      result_set.update(:name => data['result_set_data']['result_set_name'], :updated_at => Time.now)
      result_set.valid?
      {'result_set_data' => result_set.values, 'errors' => result_set.errors}
    rescue StandardError
      {'result_set_data' => ResultSet.new.values, 'errors' => [params: 'Run data is incorrect FIXME!!']} # FIXME: add validate
    end
  end

  def self.get_results(*args)
    result_set = ResultSet[:id => args.first['result_set_id']]
    begin
      [result_set.results, []]
    rescue StandardError
      [[], 'Result data is incorrect']
    end
  end
end