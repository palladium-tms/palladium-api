# frozen_string_literal: true

require_relative '../../tests/test_management'
describe 'Plan Smoke' do
  describe 'Get version' do
    it 'check getting version' do
      http = Net::HTTP.new(StaticData::ADDRESS, StaticData.port)
      request = Net::HTTP::Post.new('/public/version')
      response = http.request(request)
      expect(response.code).to eq('200')
      value = JSON.parse(response.body)['version']
      expect(value).not_to be_empty
      expect(value).to eq(File.read('VERSION').strip)
    end
  end
end
