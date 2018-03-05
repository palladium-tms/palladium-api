require 'palladium'
require_relative '../tests/test_management'

token = AuthFunctions.create_user_and_get_token
5.times do |c|
  describe 'Tests' do
    it "Paragraphs_#{c}" do
      palladium = Palladium.new(host: '0.0.0.0',
                    token: token,
                    product: "Spread" + c.to_s,
                    port: StaticData::PORT,
                    plan: "v.2",
                    run: 'Paragraphs')
      palladium.set_result(status: 'Passed', description: 'Spread | v.2 | Paragraphs', name: "Paragraphs_#{c}")
      expect(true).to eq(true)
    end
  end
end
