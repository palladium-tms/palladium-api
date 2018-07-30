class Result < Sequel::Model
  many_to_many :result_sets
  plugin :validation_helpers
  self.raise_on_save_failure = false
  plugin :timestamps

  def self.create_new(data)
    objects = ResultSet.create_new(data)
    if objects[:result_sets_errors]
      { result_errors: 'product, plan, run or result_set creating error' }.merge(objects)
    elsif data['result_data']
      result = Result.create(message: data['result_data']['message'])
      status = Status.create_new(name: data['result_data']['status'])
      status.add_result(result)
      objects[:result_sets].each do |current_result_set|
        current_result_set.add_result(result)
        current_result_set.update(status: result.status_id) unless result.status_id.nil?
      end
      objects[:result_sets].first.run.plan.update(updated_at: Time.now)
      objects.merge({result: result, status: status})
    else
      objects.merge(result_error: 'result_data not found')
    end
  end
end
