class Result < Sequel::Model
  many_to_many :result_sets
  plugin :validation_helpers
  self.raise_on_save_failure = false
  plugin :timestamps

  def self.data_valid?(data)
    if data['result_data'].nil?
      { result_data: "result_data can't be nil" }
    elsif data['result_data']['status'].nil?
      { status: "status can't be nil" }
    end
  end

  def self.get_result_and_run_id(data)
    result_set, other_data = ResultSet.create_new(data)
    other_data[:result_set_id] = result_set.id
    other_data[:run_id] = result_set.run_id
    # data['result_data']['result_set_id'] = result_set.id
    # data['run_id'] = result_set.run_id
    [other_data, [result_set]]
  end

  def self.create_new(data)
    # a = Time.now
    # Plan[name: data['plan_data']['name']].runs_dataset.select_map(:name)
    # 284.times do |i|
    #   suite = Suite.create(name: 'asdasd' + i.to_s )
    #   Product[id: 38].add_suite(suite)
    #   50.times do |j|
    #     _case = Case.create(name: 'asdasd' + i.to_s + '_' + j.to_s )
    #     suite.add_case(_case)
    #   end
    # end
    # b = Time.now - a
    # Product[id: 38].sutes << Suite.create(name: 'asdasd')
    # Suite.create(name: 'asdasd')
    errors = data_valid?(data)
    other_data = {}
    return { errors: errors } unless errors.nil?
    result_set = if data['result_data']['result_set_id'].nil?
                   result_set, other_result_set_data = ResultSet.create_new(data)
                   other_data.merge!(other_result_set_data)
                   other_data[:result_set_id] = result_set.id
                   other_data[:run_id] = result_set.run_id
                   [result_set]
                 else
                   result_set = ResultSet.where(id: data['result_data']['result_set_id'])
                   data['run_id'] = result_set.select_map(:run_id)
                   other_data[:result_set_id] = result_set.select_map(:id)
                   other_data[:run_id] = result_set.select_map(:run_id)
                   # result_set = [result_set] unless result_set.is_a?(Array)
                   result_set
                 end
    begin
      result = Result.create(message: data['result_data']['message'])
      if Status[name: data['result_data']['status']].nil?
        status = Status.create_new('name' => data['result_data']['status'])
        status.add_result(result)
        other_data.merge!(status: { status_name: data['result_data']['status'], status_color: status.color })
      else
        status = Status[name: data['result_data']['status']]
        status.update(block: false) if status.block
        Status[name: data['result_data']['status']].add_result(result) # FIXME: check speed of this method. Can be optimized
        other_data.merge!(status: { status_name: data['result_data']['status'], status_color: status.color })
      end
    rescue StandardError
      { errors: result.errors, result: result }
    end
    result_set.each do |current_result_set|
      current_result_set.add_result(result)
      current_result_set.update(status: result.status_id) unless result.status_id.nil?
    end
    [result, other_data]
  end
end
