require 'palladium'
require_relative '../tests/test_management'
token = AuthFunctions.create_user_and_get_token
palladium = Palladium.new(host: StaticData::ADDRESS,
                          token: token,
                          product: "Spread",
                          port: StaticData::PORT,
                          plan: "v.1",
                          run: 'Paragraphs0')
20.times do |c|
  describe 'Tests' do
    it "Paragraphs_#{c}" do
      palladium.set_result(status: 'LPV', description: "Spread | v.2 | Paragraphs | #{c}", name: "Paragraphs0")
      expect(true).to eq(true)
    end
  end
end
