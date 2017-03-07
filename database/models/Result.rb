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
      when result_set_id.empty?
        result.errors.add('result_set_id', "result_set_id can't be empty")
        return result_set_id
      when ResultSet[id: result_set_id].nil?
        result.errors.add('result_set_id', "result_set_id is not belongs to any result_set_id")
        return result
    end
    result
  end

  def self.create_new(data)
    data ||= {'message': ''}
    result = self.new(data)
    result.valid? # update errors stack
    result = self.result_set_validation(result, data['result_set_id'])
    if result.errors.empty?
      result = result.save
      ResultSet[id: data['result_set_id']].add_result(result)
    end
    result
  end
end