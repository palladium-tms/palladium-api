# frozen_string_literal: true

require_relative '../../tests/test_management'
describe 'Plan Smoke' do
  describe 'Get version' do
    version_from_file = File.read('VERSION').strip

    it 'check getting version with POST request' do
      http = Net::HTTP.new(StaticData::ADDRESS, StaticData.port)
      request = Net::HTTP::Post.new('/public/version')
      response = http.request(request)
      expect(response.code).to eq('200')
      value = JSON.parse(response.body)['version']
      expect(value).not_to be_empty
      expect(value).to eq(version_from_file)
    end

    it 'check getting version with GET request' do
      http = Net::HTTP.new(StaticData::ADDRESS, StaticData.port)
      request = Net::HTTP::Get.new('/public/version')
      response = http.request(request)
      expect(response.code).to eq('200')
      value = JSON.parse(response.body)['version']
      expect(value).not_to be_empty
      expect(value).to eq(version_from_file)
    end
  end
end
