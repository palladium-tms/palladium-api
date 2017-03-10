class Run < Sequel::Model
  many_to_one :plan
  one_to_many :result_sets
  plugin :validation_helpers
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
      when plan_id.empty?
        run.errors.add('plan_id', "plan_id can't be empty")
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
        return {'run_id': ["run_id can't be nil"]}
      when run_id.empty?
        return {'run_id': ["run_id can't be empty"]}
      when Run[id: run_id].nil?
        return {'run_id': ["run_id is not belongs to any plans"]}
      else
        {}
    end
  end

  def self.create_new(data)
    err_run = nil
    new_run = Run.find_or_create(name: data['name'], plan_id: data['plan_id']){|run|
      run.name = data['name']
      err_plan = run unless run.valid?
    }
    return err_run unless err_run.nil?
    run = self.plan_id_validation(new_run, data['plan_id'])
    if run.errors.empty?
      run.save
      Plan[id: data['plan_id']].add_run(run)
    end
    run
  end
end