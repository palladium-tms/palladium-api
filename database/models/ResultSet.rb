class ResultSet < Sequel::Model
  many_to_one :run
  one_to_many :results
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
    err_result_set = nil
    new_result_set = ResultSet.find_or_create(:name => data['name'], :run_id => data['run_id']){|result_set|
      result_set.name = data['name']
      result_set.status = data['status']
      err_result_set = result_set unless result_set.valid?
    }
    return err_result_set unless err_result_set.nil?
    result_set = self.run_id_validation(new_result_set, data['run_id'])
    if result_set.errors.empty?
      result_set = result_set.save
      Run[id: data['run_id']].add_result_set(result_set)
    end
    result_set
  end
end