require 'net/http'
require 'json'
class PlanFunctions

  # @param [Hash] args must has :plan_data[name] with plan name and plan_data[product_id] with product id
  def self.create_new_plan(*args)
    args.first[:name] ||= 30.times.map {StaticData::ALPHABET.sample}.join
    request = Net::HTTP::Post.new('/api/plan_new', 'Authorization' => args.first[:token])
    params = if args.first[:product_id]
               {"plan_data[product_id]": args.first[:product_id], "plan_data[name]": args.first[:name]}
             else
               {"plan_data[product_name]": args.first[:product_name], "plan_data[name]": args.first[:name]}
             end
    request.set_form_data(params)
    [request, args.first[:name]]
  end

  # @param [Hash] args must has :product_id with product_id or :product_name with product name
  def self.get_plans(*args)
    request = Net::HTTP::Post.new('/api/plans', 'Authorization' => args.first[:token])
    params = if args.first[:product_id]
               {"plan_data[product_id]": args.first[:product_id]}
             else
               {"plan_data[product_name]": args.first[:product_name]}
             end
    request.set_form_data(params)
    request
  end

  # @param [Hash] args must has :plan_id[id] with plan id for deleting
  def self.delete_plan(*args)
    request = Net::HTTP::Post.new('/api/plan_delete', 'Authorization' => args.first[:token])
    request.set_form_data({ "plan_data[id]": args.first[:id]})
    request
  end

  def self.update_plan(*args)
    request = Net::HTTP::Post.new('/api/plan_edit', 'Authorization' => args.first[:token])
    request.set_form_data({"plan_data[id]": args.first[:id], "plan_data[plan_name]": args.first[:name]})
    request
  end
end