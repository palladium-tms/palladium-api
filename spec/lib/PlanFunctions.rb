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
    uri = URI(StaticData::MAINPAGE + '/plan_delete')
    uri.query = URI.encode_www_form(args.first)
    Net::HTTP::Delete.new(uri)
  end

  def self.update_plan(*args)
    request = Net::HTTP::Post.new('/plan_edit', 'Content-Type' => 'application/json')
    request.set_form_data(args.first)
    request
  end
  #
  #
  # # @param [Hash] account like a {:email => 'email_from_account', :password => 'password_from_account'}
  # # @param [Integer] id is a id of product for deleting
  # # return hash which keys - id of product, values - is a hash {'name': 'product_name'}
  # def self.delete_product(account, id)
  #   uri = URI(StaticData::MAINPAGE + '/product_delete')
  #   uri.query = URI.encode_www_form({"user_data[email]": account[:email], "user_data[password]":  account[:password], "product_data[id]": id})
  #   Net::HTTP::Delete.new(uri)
  # end
  #
  # # @param [Hash] account like a {:email => 'email_from_account', :password => 'password_from_account'}
  # # @param [Hash] product_data like a {:id => product_id, :name => product_name}
  # def self.update_product(account, product_data)
  #   request = Net::HTTP::Post.new('/product_edit', 'Content-Type' => 'application/json')
  #   request.set_form_data({"user_data[email]": account[:email], "user_data[password]":  account[:password],
  #                          "product_data[id]": product_data[:id], "product_data[name]": product_data[:name]})
  #   request
  # end
  #
  # # @param [Hash] account like a {:email => 'email_from_account', :password => 'password_from_account'}
  # # @param [Integer] id is a id of product for deleting
  # def self.show_product(account, id)
  #   uri = URI(StaticData::MAINPAGE + '/product')
  #   uri.query = URI.encode_www_form({"user_data[email]": account[:email], "user_data[password]":  account[:password], "product_data[id]": id})
  #   result = JSON.parse(Net::HTTP.get_response(uri).body)
  #   if result['product'].empty?
  #     {'product': [], 'errors': result['errors']}
  #   else
  #     {id: result['product']['id'], name: result['product']['name'], created_at: result['product']['created_at'], updated_at: result['product']['updated_at']}
  #   end
  # end
end