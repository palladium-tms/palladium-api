require 'net/http'
require 'json'
TOKEN = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0OTgyMzI0MTYsImlhdCI6MTQ5ODIyODgxNiwiaXNzIjoic2FkYXNkYXNmcmdhd2U0cndlciIsInNjb3BlcyI6WyJwcm9kdWN0cyIsInByb2R1Y3RfbmV3IiwicHJvZHVjdF9kZWxldGUiLCJwcm9kdWN0X2VkaXQiLCJwbGFuX25ldyIsInBsYW5zIiwicGxhbl9lZGl0IiwicGxhbl9kZWxldGUiLCJydW5fbmV3IiwicnVucyIsInJ1bl9kZWxldGUiLCJydW5fZWRpdCIsInJlc3VsdF9zZXRfbmV3IiwicmVzdWx0X3NldHMiLCJyZXN1bHRfc2V0X2RlbGV0ZSIsInJlc3VsdF9zZXRfZWRpdCIsInJlc3VsdF9uZXciLCJyZXN1bHRzIiwic3RhdHVzX25ldyIsInN0YXR1c2VzIiwic3RhdHVzX2VkaXQiXSwidXNlciI6eyJlbWFpbCI6IjFAZy5jb20ifX0.6XXkp0uAwin8WSur_gopNr-oYntFS5vOCo44xN-PBk0'
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
    request = Net::HTTP::Post.new('/api/result_new', 'Authorization' => TOKEN)
    params = {"plan_data[product_name]": @product,
              "plan_data[name]": @plan,
              "run_data[name]": 'multiplication_products1',
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
1.times do |i|

  product = "Product_0"
  1.times do |j|
plan = "v.9_#{0}.#{0}"
    run = File.basename(__FILE__, '_spec.rb')
    auth = {host: '0.0.0.0', port: '9292', token: TOKEN}
    palladium = Palladium.new({:product => product,
                               :plan => plan,
                               :run => run,
                               :auth => auth})
    1.times do
    40.times do |c|
      describe 'Tests' do
        it "1*1+c" do
          true
        end
        it "1*2+#{c}" do
          expect(true).to eq(false)
        end
        it "1*3+#{c}" do
          true
        end
        it "1*4+#{c}" do
          expect(true).to eq(false)
        end
        it "1*5+#{c}" do
          true
        end
        it "1*6+#{c}" do
          expect(true).to eq(false)
        end
        it "1*7+#{c}" do
          true
        end
        it "1*8+#{c}" do
          expect(true).to eq(false)
        end
        it "1*9+#{c}" do
          true
        end
        after :each do |example|
          $j +=1
          palladium.set_result(example)
        end
      end
      end
    end
  end
end

