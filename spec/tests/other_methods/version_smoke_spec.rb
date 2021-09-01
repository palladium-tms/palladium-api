require_relative '../../tests/test_management'
describe 'Plan Smoke' do
  describe 'Get version' do
    it 'check getting version' do
      http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
      request = Net::HTTP::Post.new('/public/version')
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['version'].empty?).to be_falsey
    end
  end
end
