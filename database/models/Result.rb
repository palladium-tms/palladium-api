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
    a = Time.now
    data.merge!({'run_id' => nil})
    if data['result_data']['result_set_id'].nil?
      result_set = ResultSet.create_new(data)
      data['result_data']['result_set_id'] = result_set.id
      data['run_id'] = result_set.run_id
    end

    begin
      result = Result.create(message:  data['result_data']['message'], result_set_id:  data['result_data']['result_set_id'])
      if Status[name: data['result_data']['status']].nil?
        status = Status.create_new({'status_name' =>  data['result_data']['status']})
        status.add_result(result)
      else
        Status[name: data['result_data']['status']].add_result(result)
      end
    rescue StandardError
      return self.result_set_validation(Run.new(data['result_set_data']), data['plan_data']['plan_id'])
    end
    result_set = ResultSet[id: data['result_data']['result_set_id']]
    result_set.add_result(result)
    result_set.update(status: result.status_id) unless result.status_id.nil?
    puts Time.now - a
    [result, data['run_data']['id']]
  end
end