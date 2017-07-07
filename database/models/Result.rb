class Result < Sequel::Model
  many_to_many :result_sets
  plugin :validation_helpers
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def self.data_valid?(data)
    case
      when data['result_data'].nil?
        return {result_data: "result_data can't be nil"}
      when data['result_data']['status'].nil?
        {status: "status can't be nil"}
    end
  end

  def self.get_result_and_run_id(data)
    result_set = ResultSet.create_new(data)
    data['result_data']['result_set_id'] = result_set.id
    data['run_id'] = result_set.run_id
    [data, [result_set]]
  end

  def self.create_new(data)
    errors = data_valid?(data)
    return {errors: errors} unless errors.nil?
    if data['result_data']['result_set_id'].nil?
      data, result_set = get_result_and_run_id(data)
    else
      result_set = ResultSet.where(id: data['result_data']['result_set_id'])
      data['run_id'] = result_set.select_map(:run_id)
      data['result_set_id'] = result_set.select_map(:id)
    end
    begin
      result = Result.create(message:  data['result_data']['message'])
      if Status[name: data['result_data']['status']].nil?
        status = Status.create_new({'status_name' =>  data['result_data']['status']})
        status.add_result(result)
      else
        Status[name: data['result_data']['status']].add_result(result)
      end
    rescue StandardError
      {errors: result.errors, result: result}
    end
    result_set.each do |current_result_set|
      current_result_set.add_result(result)
      current_result_set.update(status: result.status_id) unless result.status_id.nil?
    end
    {result: result, run_id: data['run_id'], result_set_id: data['result_set_id'] }
  end
end