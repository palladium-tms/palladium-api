require 'net/http'
require 'json'
require_relative '../tests/test_management'
class Palladium
  def initialize(options = {})
    options[:port] ||= 80
    @http = Net::HTTP.new(options[:host], options[:port])
    @product = options[:product]
    @plan = options[:plan]
    @run = options[:run]
    @token = options[:token]
    @run_id = nil
  end

  def set_result(options = {})
    p options
    request = Net::HTTP::Post.new('/api/result_new', 'Authorization' => @token)
    params = { 'plan_data[product_name]' => @product,
               'plan_data[name]' => @plan,
               'run_data[name]' => options[:run_name],
               'result_set_data[name]' => options[:name],
               'result_data[message]' => options[:description],
               'result_data[status]' => options[:status] }
    params['result_set_data[run_id]'] = @run_id unless @run_id.nil?
    request.set_form_data(params)
    result = JSON.parse(@http.request(request).body)
    @run_id = result['run_id']
    result
  end
end


token = AuthFunctions.create_user_and_get_token
product = "Product_1"

palladium = Palladium.new(host: '0.0.0.0',
                          token: AuthFunctions.create_user_and_get_token,
                          product: product,
                          port: 9292,
                          plan: 'v.8.0',
                          run: File.basename(__FILE__, '_spec.rb'))

$j = 0
40.times do |i|
  1.times do |j|



    describe 'Tests' do
      it "1*1+c" do
        true
      end
      after :each do |example|
        $j +=1
        # result = palladium.get_result(example)
        # palladium.set_result(result)
        palladium.set_result(status: 'Passed', description: 'Not right', name: example.metadata[:description], run_name: File.basename(__FILE__))
      end
    end
  end
end

