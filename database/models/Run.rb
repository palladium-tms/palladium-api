class Run < Sequel::Model
  many_to_one :plan
  one_to_many :result_sets
  plugin :validation_helpers
  plugin :association_dependencies
  self.add_association_dependencies :result_sets=>:destroy
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
    data['run_data']['plan_id'] ||= Plan.create_new(data).id
    begin
      run = Run.find_or_create(name:  data['run_data']['name'], plan_id:  data['run_data']['plan_id']){|run|
        run.name =  data['run_data']['name']
      }
    rescue StandardError
      return self.plan_id_validation(Plan.new(data['plan_data']), data['plan_data']['plan_id'])
    end
    Plan[id: data['run_data']['plan_id']].add_run(run)
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
    run =  Run[:id => args.first['run_id']]
    begin
      [run.result_sets, []]
    rescue StandardError
      [[], 'Result_set data is incorrect']
    end
  end
end