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
      when Run[id: run_id].nil?
        result_set.errors.add('run_id', "run_id is not belongs to any plans")
        return result_set
    end
    result_set
  end

  def self.create_new(data)
    data['result_set_data']['run_id'] ||= Run.create_new(data).id
    begin
      result_set = ResultSet.find_or_create(name:  data['result_set_data']['name'], run_id:  data['result_set_data']['run_id']){|result_set|
        result_set.name =  data['result_set_data']['name']
      }
    rescue StandardError
      return self.run_id_validation(Run.new(data['result_set_data']), data['plan_data']['plan_id'])
    end
    Run[id: data['result_set_data']['run_id']].add_result_set(result_set)
  end
end