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
  def self.get_runs(*args)
    request = Net::HTTP::Post.new('/api/runs', 'Authorization' => args.first[:token])
    request.set_form_data(  {"run_data[plan_id]": args.first[:plan_id]})
    request
  end

  # @param [Hash] args must has :run_data[name] with plan name and run_data[plan_id] with plan id
  def self.delete_run(*args)
    request = Net::HTTP::Post.new('/api/run_delete', 'Authorization' => args.first[:token])
    request.set_form_data({ "run_data[id]": args.first[:id]})
    request
  end
end