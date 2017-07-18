require 'palladium'
TOKEN = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MDAzODQyMTYsImlhdCI6MTUwMDM4MDYxNiwiaXNzIjoic29tZWF3ZXNvbWVzZWNyZXQiLCJzY29wZXMiOlsicHJvZHVjdHMiLCJwcm9kdWN0X25ldyIsInByb2R1Y3RfZGVsZXRlIiwicHJvZHVjdF9lZGl0IiwicGxhbl9uZXciLCJwbGFucyIsInBsYW5fZWRpdCIsInBsYW5fZGVsZXRlIiwicnVuX25ldyIsInJ1bnMiLCJydW5fZGVsZXRlIiwicnVuX2VkaXQiLCJyZXN1bHRfc2V0X25ldyIsInJlc3VsdF9zZXRzIiwicmVzdWx0X3NldF9kZWxldGUiLCJyZXN1bHRfc2V0X2VkaXQiLCJyZXN1bHRfbmV3IiwicmVzdWx0cyIsInN0YXR1c19uZXciLCJzdGF0dXNlcyIsInN0YXR1c19lZGl0Il0sInVzZXIiOnsiZW1haWwiOiIxQGcuY29tIn19.fgOGDbqmYFDYSyQIKZ_InSR9Iyb4qnNDkXCvuKxpyEU'.freeze
product_count = 1
plan_count = 1
product_count.times do |product_iterator|
  plan_count.times do |plan_iterator|
    product = "Product_#{product_iterator}"
    plan = "v.#{plan_iterator}"
    run = File.basename(__FILE__, '_spec.rb')
    palladium = Palladium.new(host: '0.0.0.0',
                              token: TOKEN,
                              product: product,
                              plan: plan,
                              run: run)
    1.times do
      40.times do |c|
        describe 'Tests' do
          it '1*1+c' do
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
            a = palladium.set_result(status: 'True', description: 'Not right', name: example.metadata[:description])
            p
          end
        end
      end
    end
  end
end
