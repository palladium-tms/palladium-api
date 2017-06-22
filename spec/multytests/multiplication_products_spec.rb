require 'net/http'
require 'json'
require_relative '../../data/tic_data'
class Palladium
  def initialize(*args)
    @http = Net::HTTP.new(args.first[:auth][:host], args.first[:auth][:port])
    @product = args.first[:product]
    @plan = args.first[:plan]
    @run = args.first[:run]
    @run_id = nil
  end

  def set_result(example)
    result = get_result(example)
    request = Net::HTTP::Post.new('/api/result_new', 'Authorization' => StaticData::TOKEN)
    params = {"plan_data[product_name]": @product,
              "plan_data[name]": @plan,
              "run_data[name]": @run + $j.to_s,
              "result_set_data[name]": example.metadata[:description],
              "result_data[message]": "message_1",
              "result_data[status]": "#{result.first}"}
    request.set_form_data(params)
    params.merge!({"result_set_data[run_id]": @run_id}) unless @run_id.nil?
    @run_id = JSON.parse(@http.request(request).body)['run_id']
  end

  def get_result(example)
    case
      when example.exception.nil?
        [:Passed, '']
      when errors_is_contains?(example, %w(got: expected: return))
        [:Failed, "\n#{example.exception.to_s.gsub('got:', "got:\n").gsub('expected:', "expected:\n")}\nIn line:\n#{example.exception}"]
    end
  end

  def errors_is_contains?(example, errors)
    result = false
    errors.each do |current_error|
      result = true if example.exception.to_s.include?(current_error)
    end
    result
  end
end
$j = 0
40.times do |i|

  product = "Product_#{i}"
  1.times do |j|
plan = "v.8_#{i}.#{j}"
    run = File.basename(__FILE__, '_spec.rb')
    auth = {host: '0.0.0.0', port: '9292', token: StaticData::TOKEN}
    palladium = Palladium.new({:product => product,
                               :plan => plan,
                               :run => run,
                               :auth => auth})
      describe 'Tests' do
        it "1*1+c" do
          true
        end
        after :each do |example|
          $j +=1
          palladium.set_result(example)
        end
    end
  end
end

