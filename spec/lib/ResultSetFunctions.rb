require 'net/http'
require 'json'
class ResultSetFunctions
  # @param [Hash] args must has 'run_data[plan_id]' with plan id, and can has run_data[name] with name (or will be generate
  # random name). example: {"run_data[name]" => "string", "run_data[plan_id]" => int }
  def self.create_new_result_set(*args)
    args.first['result_set_data[name]'] ||= 30.times.map { StaticData::ALPHABET.sample }.join
    request = Net::HTTP::Post.new('/result_set_new', 'Content-Type' => 'application/json')
    request.set_form_data(args.first)
    [request, args.first['result_set_data[name]']]
  end

  # @param [Hash] args must has result_set_data[run_id](int) with run id
  # example: "result_set_data[run_id]" => run['id']
  def self.get_result_sets(*args)
    uri = URI(StaticData::MAINPAGE + '/result_sets')
    params = args.first
    uri.query = URI.encode_www_form(params)
    hash_with_result_sets = {}
    result = JSON.parse(Net::HTTP.get_response(uri).body)
    if result['errors'].empty?
      JSON.parse(Net::HTTP.get_response(uri).body)['result_sets'].map do |result_set|
        hash_with_result_sets.merge!({result_set['id'] => {'id' => result_set['id'],
                                                          'name' => result_set['name'],
                                                          'status' => result_set['status'],
                                                          'run_id' => result_set['run_id'],
                                                          'created_at' => result_set['created_at'],
                                                          'updated_at' => result_set['updated_at']}})
      end
      hash_with_result_sets
    else
      result
    end
  end
end