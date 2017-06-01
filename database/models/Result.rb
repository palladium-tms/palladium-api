class Result < Sequel::Model
  many_to_one :result_sets
  plugin :validation_helpers
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def self.result_set_validation(result, result_set_id)
    case
      when result_set_id.nil?
        result.errors.add('result_set_id', "result_set_id can't be nil")
        return result
      when ResultSet[id: result_set_id].nil?
        result.errors.add('result_set_id', "result_set_id is not belongs to any result_set_id")
        return result
    end
    result
  end

  def self.create_new(data)
    data['result_data']['result_set_id'] ||= ResultSet.create_new(data).id
    begin
      result = Result.create(message:  data['result_data']['message'], result_set_id:  data['result_data']['result_set_id'])
    rescue StandardError
      return self.run_id_validation(Run.new(data['result_set_data']), data['plan_data']['plan_id'])
    end
    result_set = ResultSet[id: data['result_data']['result_set_id']]
    result_set.add_result(result)
    result_set.update(status: result.status_id) unless result.status_id.nil?
    result_set
  end
end