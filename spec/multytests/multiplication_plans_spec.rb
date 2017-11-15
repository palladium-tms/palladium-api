require 'palladium'
require_relative '../tests/test_management'

token = AuthFunctions.create_user_and_get_token
1.times do |c|
  describe 'Tests' do
    it "Paragraphs" do
      palladium = Palladium.new(host: '0.0.0.0',
                                token: token,
                                product: "Spread",
                                port: StaticData::PORT,
                                plan: "v.2" + + c.to_s,
                                run: 'Paragraphs')
      palladium.set_result(status: 'Failed', description: 'Spread | v.2 | Paragraphs', name: "Paragraphs")
      expect(true).to eq(true)
    end
  end
end
