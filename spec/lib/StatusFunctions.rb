require 'net/http'
require 'json'
class StatusFunctions
  # @param [Hash] args must has 'result_data[result_set_id_id]' with result_set id, and can has result_data[message] with hash of messages (or will be generate
  # random message). example: {"result_data[result_set_id_id]" => int, "result_data[message]" => hash }
  def self.create_new_status(*args)
    args.first['status_data[name]'] ||= 30.times.map { StaticData::ALPHABET.sample }.join
    request = Net::HTTP::Post.new('/status_new', 'Content-Type' => 'application/json')
    request.set_form_data(args.first)
    [request, args.first['status_data[name]']]
  end
end