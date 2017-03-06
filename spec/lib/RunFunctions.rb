require 'net/http'
require 'json'
class RunFunctions
  # @param [Hash] args must has 'run_data[plan_id]' with plan id, and can has run_data[name] with name (or will be generate
  # random name). example: {"run_data[name]" => "string", "run_data[plan_id]" => int }
  def self.create_new_run(*args)
    args.first['run_data[name]'] ||= 30.times.map { StaticData::ALPHABET.sample }.join
    request = Net::HTTP::Post.new('/run_new', 'Content-Type' => 'application/json')
    request.set_form_data(args.first)
    [request, args.first['run_data[name]']]
  end

  # @param [Hash] args must has :run_data[name] with plan name and run_data[plan_id] with plan id
  def self.get_plans(*args)
    uri = URI(StaticData::MAINPAGE + '/runs')
    params = args.first
    uri.query = URI.encode_www_form(params)
    hash_with_products = {}
    result = JSON.parse(Net::HTTP.get_response(uri).body)
    if result['errors'].nil?
      JSON.parse(Net::HTTP.get_response(uri).body)['plans'].map do |current_plan|
        hash_with_products.merge!({current_plan['id'] => {'id' => current_plan['id'],
                                                          'name' => current_plan['name'],
                                                          'product_id' => current_plan['product_id'],
                                                          'created_at' => current_plan['created_at'],
                                                          'updated_at' => current_plan['updated_at']}})
      end
      hash_with_products
    else
      result
    end
  end
end