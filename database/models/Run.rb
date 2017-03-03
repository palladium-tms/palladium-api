class Run < Sequel::Model
  many_to_one :plan
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

  def self.create_new(data)
    data ||= {'name': ''}
    run = self.new(name: data['name'])
    run.valid? # update errors stack
    run = self.plan_id_validation(run, data['plan_id'])
    if run.errors.empty?
      run.save
      Plan[id: data['plan_id']].add_run(run)
    end
    run
  end
end