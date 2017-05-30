require 'net/http'
require 'json'
class RunFunctions
  # @param [Hash] args must has :plan_id with plan id, and can has run_name with name (or will be generate
  # random name). example: {:run_name => "string", :plan_id => int }
  # examples:
  # {token: token, plan_id: int, run_name: str} - creating RUN(run_name) for PLAN(plan_id)
  # {token: token, plan_name: str, product_id: int, run_name: str} - creating RUN(run_name) and PLAN(plan_name). run for plan
  # {token: token, plan_name: str, product_name: str, run_name: str} - creating RUN(run_name) and PLAN(plan_name) and PRODUCT(product_name)
  def self.create_new_run(*args)
    args.first[:run_name] ||= 30.times.map { StaticData::ALPHABET.sample }.join
    request = Net::HTTP::Post.new('/api/run_new', 'Authorization' => args.first[:token])
    params = if args.first[:plan_id]
               {"run_data[plan_id]": args.first[:plan_id], "run_data[name]": args.first[:run_name]}
             elsif args.first[:product_id]
               {"plan_data[name]": args.first[:product_id],
                "plan_data[product_id]": args.first[:product_id],
                "run_data[name]": args.first[:run_name]}
             else
               {"plan_data[name]": args.first[:plan_name],
                "run_data[name]": args.first[:run_name],
                "plan_data[product_name]": args.first[:product_name]}
             end
    request.set_form_data(params)
    [request, args.first[:run_name] ]
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

  # @param [Hash] args must has :run_data[name] with plan name and run_data[plan_id] with plan id
  def self.delete_run(*args)
    uri = URI(StaticData::MAINPAGE + '/run_delete')
    uri.query = URI.encode_www_form(args.first)
    Net::HTTP::Delete.new(uri)
  end
end