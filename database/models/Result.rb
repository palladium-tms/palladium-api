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
    result = self.new('message' => data['result_data']['message'])
    result.valid? # update errors stack
    result = self.result_set_validation(result, data['result_data']['result_set_id'])
    if result.errors.empty?
      status = Status.find_or_create(:name => data['result_data']['status']){|status| status.name = data['result_data']['status']; status.block = false; status.color = "#ffffff" }
      result = result.save
      ResultSet[id: data['result_data']['result_set_id']].add_result(result)
      status.add_result(result)
      ResultSet[:id => data['result_data']['result_set_id']].update(:status => status.id)
    end
    result
  end
end