class ResultSet < Sequel::Model
  many_to_one :run
  one_to_many :results
  plugin :validation_helpers
  plugin :association_dependencies
  self.add_association_dependencies :results=>:destroy
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

  def self.edit(data)
    begin
      result_set = ResultSet[:id => data['result_set_data']['id']]
      result_set.update(:name => data['result_set_data']['result_set_name'], :updated_at => Time.now)
      result_set.valid?
      {'result_set_data': result_set.values, 'errors': result_set.errors}
    rescue StandardError
      {'result_set_data': ResultSet.new.values, 'errors': [params: 'Run data is incorrect FIXME!!']} # FIXME: add validate
    end
  end

  def self.get_results(*args)
    result_set =  ResultSet[:id => args.first['result_set_id']]
    begin
      [result_set.results, []]
    rescue StandardError
      [[], 'Result data is incorrect']
    end
  end
end