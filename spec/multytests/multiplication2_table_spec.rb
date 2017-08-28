require 'palladium'
require_relative '../tests/test_management'


token = AuthFunctions.create_user_and_get_token
product_count = 1
plan_count = 1
product_count.times do |product_iterator|
  plan_count.times do |plan_iterator|
    product = "Product_#{product_iterator}"
    plan = "v.#{plan_iterator}"
    run = File.basename(__FILE__, '_spec.rb')
    palladium = Palladium.new(host: '0.0.0.0',
                              token: token,
                              product: product,
                              port: StaticData::PORT,
                              plan: plan,
                              run: run)
    1.times do
      40.times do |c|
        describe 'Tests' do
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
            a = palladium.set_result(status: 'False', description: 'Not right', name: example.metadata[:description])
            p
          end
        end
      end
    end
  end
end
