require 'palladium'
require_relative '../tests/test_management'

token = AuthFunctions.create_user_and_get_token
palladium = Palladium.new(host: '0.0.0.0',
                          token: token,
                          product: "Documents",
                          port: StaticData::PORT,
                          plan: "v.1",
                          run: 'Paragraphs')
5.times do |c|
  describe 'Tests' do
    it "Paragraphs_#{c}" do
      palladium.set_result(status: 'Passed', description: 'Documents | v.1 | Paragraphs', name: "Paragraphs_#{c}")
      expect(true).to eq(true)
    end

    it "Paragraphs_#{c}_false" do
      palladium.set_result(status: 'Failed', description: 'Documents | v.1 | Paragraphs', name: "Paragraphs_#{c}_false")
      expect(true).to eq(false)
    end
  end
end
palladium.run = 'Styles'
5.times do |c|
  describe 'Tests' do
    it "Styles_#{c}" do
      palladium.set_result(status: 'Passed', description: 'Documents | v.1 | Styles', name: "Styles_#{c}")
      expect(true).to eq(true)
    end

    it "Styles_#{c}_false" do
      palladium.set_result(status: 'Failed', description: 'Documents | v.1 | Styles', name: "Styles_#{c}_false")
      expect(true).to eq(false)
    end
  end
end
palladium.run = 'Fonts'
5.times do |c|
  describe 'Tests' do
    it "Fonts_#{c}" do
      palladium.set_result(status: 'Passed', description: 'Documents | v.1 | Paragraphs', name: "Fonts_#{c}")
      expect(true).to eq(true)
    end

    it "Fonts_#{c}_false" do
      palladium.set_result(status: 'Failed', description: 'Documents | v.1 | Paragraphs', name: "Fonts_#{c}_false")
      expect(true).to eq(false)
    end
  end
end
