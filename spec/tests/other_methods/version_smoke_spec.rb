# frozen_string_literal: true

require_relative '../../tests/test_management'
describe 'Plan Smoke' do
  describe 'Get version' do
    it 'check getting version' do
      http = Net::HTTP.new(StaticData::ADDRESS, StaticData.port)
      request = Net::HTTP::Post.new('/public/version')
      response = http.request(request)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['version']).not_to be_empty
    end
  end
end
