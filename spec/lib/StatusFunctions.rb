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

  def self.get_all_statuses(*args)
    uri = URI(StaticData::MAINPAGE + '/statuses')
    uri.query = URI.encode_www_form(args.first)
    hash_with_statuses = {}
    JSON.parse(Net::HTTP.get_response(uri).body)['statuses'].
        map {|current_status|
      hash_with_statuses.merge!({current_status['id'] => {'id' => current_status['id'],
                                                          'name' => current_status['name'],
                                                          'block' => current_status['block'],
                                                          'color' => current_status['color']}})}
    hash_with_statuses
  end

  def self.status_block(*args)
    request = Net::HTTP::Post.new('/status_block', 'Content-Type' => 'application/json')
    request.set_form_data(args.first)
    request
  end
end