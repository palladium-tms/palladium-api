class ResultSet < Sequel::Model
  many_to_one :runs
  plugin :validation_helpers
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
    validates_integer :status
  end

  def self.run_id_validation(result_set, run_id)
    case
      when run_id.nil?
        result_set.errors.add('run_id', "run_id can't be nil")
        return result_set
      when run_id.empty?
        result_set.errors.add('run_id', "run_id can't be empty")
        return result_set
      when Run[id: run_id].nil?
        result_set.errors.add('run_id', "run_id is not belongs to any plans")
        return result_set
    end
    result_set
  end

  def self.create_new(data)
    data ||= {'name': ''}
    result_set = self.new(data)
    result_set.valid? # update errors stack
    result_set = self.run_id_validation(result_set, data['run_id'])
    if result_set.errors.empty?
      result_set = result_set.save
      Run[id: data['run_id']].add_result_set(result_set)
    end
    result_set
  end
end