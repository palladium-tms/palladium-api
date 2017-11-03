require 'palladium'
require_relative '../tests/test_management'

token = AuthFunctions.create_user_and_get_token
palladium = Palladium.new(host: '0.0.0.0',
                          token: token,
                          product: "Spread",
                          port: StaticData::PORT,
                          plan: "v.2",
                          run: 'Paragraphs')
20.times do |c|
  describe 'Tests' do
    it "Paragraphs_#{c}" do
        palladium.set_result(status: 'Passed', description: "Spread | v.2 | Paragraphs | #{c}", name: "Paragraphs_0")
      expect(true).to eq(true)
    end
  end
end
