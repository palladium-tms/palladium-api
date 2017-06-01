require 'net/http'
require 'json'
class StatusFunctions
  # @param [Hash] args must has 'result_data[result_set_id_id]' with result_set id, and can has result_data[message] with hash of messages (or will be generate
  # random message). example: {"result_data[result_set_id_id]" => int, "result_data[message]" => hash }
  def self.create_new_status(*args)
    request = Net::HTTP::Post.new('/api/status_new', 'Authorization' => args.first[:token])
    params = {'status_data[status_name]': args.first[:name]}
    params.merge!('status_data[status_color]': args.first[:color]) if args.first[:color]
    request.set_form_data(params)
    request
  end

  def self.get_all_statuses(token)
    url = URI.parse(StaticData::MAINPAGE + '/api/statuses')
    req = Net::HTTP::Get.new(url.path)
    req[:Authorization] = token
    res = Net::HTTP.new(url.host, url.port).start do |http|
      http.request(req)
    end
    result = {}
    JSON.parse(res.body)['statuses'].each do |current_product|
      result.merge!({current_product['id'] => current_product})
    end
    result
  end

  def self.status_edit(*args)
    request = Net::HTTP::Post.new('/api/status_edit', 'Authorization' => args.first[:token])
    request.set_form_data(params(args.first))
    request
  end

  def self.params(param)
    params = {}
    params.merge!({'status_data[id]': param[:id]}) if param[:id]
    params.merge!({'status_data[name]': param[:name]}) if param[:name]
    params.merge!({'status_data[color]': param[:color]}) if param[:color]
    params.merge!({'status_data[block]': param[:block]}) unless param[:block].nil?
    params
  end
end