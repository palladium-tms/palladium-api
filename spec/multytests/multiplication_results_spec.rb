require 'palladium'
require_relative '../tests/test_management'

palladium = Palladium.new(host: StaticData::ADDRESS,
                          token: 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjI1MjQ1OTcyMDAsImlhdCI6MTUxNjIwMDQ3MSwiaXNzIjoiQVBJIiwic2NvcGVzIjpbInJlc3VsdF9uZXciXSwidXNlciI6eyJlbWFpbCI6InFnZHdoaXV4bm1AZy5jb20ifX0.g4oBgOnXbRy5N2zXPuvvgFeAVjpd7tflOU6QlvSrE0A',
                          product: "Spread",
                          port: StaticData::PORT,
                          plan: "v.2",
                          run: 'Paragraphs0')
20.times do |c|
  describe 'Tests' do
    it "Paragraphs_#{c}" do
      palladium.set_result(status: 'LPV', description: "Spread | v.2 | Paragraphs | #{c}", name: "Paragraphs0")
      expect(true).to eq(true)
    end
  end
end
