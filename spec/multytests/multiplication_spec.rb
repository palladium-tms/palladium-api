require 'palladium'
require_relative '../tests/test_management'

token = AuthFunctions.create_user_and_get_token
palladium = Palladium.new(host: '0.0.0.0',
                          token: token,
                          product: "Spread",
                          port: StaticData::PORT,
                          plan: "v.2",
                          run: 'Paragraphs')
5.times do |c|
  describe 'Tests' do
    it "Paragraphs_#{c}" do
      palladium.set_result(status: 'Passed', description: 'Spread | v.2 | Paragraphs', name: "Paragraphs_#{c}")
      expect(true).to eq(true)
    end

    it "Paragraphs_#{c}_false" do
      palladium.set_result(status: 'Failed', description: 'Spread | v.2 | Paragraphs', name: "Paragraphs_#{c}_false")
      expect(true).to eq(false)
    end
  end
end
5.times do |c|
  describe 'Tests' do
    it "Styles_#{c}" do
      Palladium.new(host: '0.0.0.0',
                    token: token,
                    product: "Spread",
                    port: StaticData::PORT,
                    plan: "v.2",
                    run: 'Styles').set_result(status: 'Passed', description: 'Spread | v.2 | Styles', name: "Styles_#{c}")
      expect(true).to eq(true)
    end

    it "Styles_#{c}_false" do
      Palladium.new(host: '0.0.0.0',
                    token: token,
                    product: "Spread",
                    port: StaticData::PORT,
                    plan: "v.2",
                    run: 'Styles').set_result(status: 'Failed', description: 'Spread | v.2 | Styles', name: "Styles_#{c}_false")
      expect(true).to eq(false)
    end
  end
end
5.times do |c|
  describe 'Tests' do
    it "Fonts_#{c}" do
      Palladium.new(host: '0.0.0.0',
                    token: token,
                    product: "Spread",
                    port: StaticData::PORT,
                    plan: "v.2",
                    run: 'Fonts').set_result(status: 'Passed', description: 'Spread | v.2 | Paragraphs', name: "Fonts_#{c}")
      expect(true).to eq(true)
    end

    it "Fonts_#{c}_false" do
      Palladium.new(host: '0.0.0.0',
                    token: token,
                    product: "Spread",
                    port: StaticData::PORT,
                    plan: "v.2",
                    run: 'Fonts').set_result(status: 'Failed', description: 'Spread | v.2 | Paragraphs', name: "Fonts_#{c}_false")
      expect(true).to eq(false)
    end
  end
end
