require 'rspec'
require 'net/http'
require 'json'
require_relative '../../data/static_data'
require_relative '../../lib/AuthFunctions'
http = nil
describe 'Smoke' do
  before :all do
    http = Net::HTTP.new(StaticData::ADDRESS, StaticData::PORT)
  end

  describe '/login page' do
    it 'check login page loading' do
      response = Net::HTTP.get_response(StaticData::ADDRESS, '/login', StaticData::PORT)
      expect(response.body).to eq(File.open(File.dirname(__FILE__) + '/../../../views/login.erb'){ |file| file.read})
      expect(response.message).to eq('OK')
      expect(response.code).to eq('200')
    end

    it 'try login with uncorrect request' do
      request = Net::HTTP::Post.new('/login')
      request.set_form_data({"q" => "My query", "per_page" => "50"})
      response = http.request(request)
      expect(response.code).to eq('500')
    end

    it 'try login with uncorrect user_data' do
      request = Net::HTTP::Post.new('/login')
      email = 10.times.map { StaticData::ALPHABET.sample }.join + '@g.com'
      password = 7.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({'user_data' => {'email' => email, 'password' => password}})
      response = http.request(request)
      expect(response.code).to eq('201')
      expect(JSON.parse(response.body)['errors']).to eq(ErrorMessages::UNCORRECT_LOGIN)
    end
  end

  describe '/registration' do
    it 'check registration page loading' do
      response = Net::HTTP.get_response(StaticData::ADDRESS, '/registration', StaticData::PORT)
      expect(response.body).to eq(File.open(File.dirname(__FILE__) + '/../../../views/registration.erb'){ |file| file.read})
      expect(response.message).to eq('OK')
      expect(response.code).to eq('200')
    end

    it 'try to registrarion with uncorrect request' do
      request = Net::HTTP::Post.new('/registration')
      request.set_form_data({"q" => "My query", "per_page" => "50"})
      response = http.request(request)
      expect(response.code).to eq('500')
    end

    it 'try to registrarion with uncorrect user_data | without g.com' do
      request = Net::HTTP::Post.new('/registration')
      email = 10.times.map { StaticData::ALPHABET.sample }.join
      password = 7.times.map { StaticData::ALPHABET.sample }.join
      request.set_form_data({'user_data' => {'email' => email, 'password' => password}})
      response = http.request(request)
      expect(response.body).to eq('Sorry there was a nasty error - no implicit conversion of Symbol into Integer')
      expect(response.code).to eq('500')
    end

    it 'try to registrarion with correct data' do
      response = http.request(AuthFunctions.create_new_account[0])
      expect(response.code).to eq('200')
    end
  end

  describe '/ page' do
    it 'check / page loading without login' do
      response = Net::HTTP.get_response(StaticData::ADDRESS, '/', StaticData::PORT)
      expect(response.code).to eq('302')
      expect(response['location']).to eq("http://#{StaticData::MAINPAGE}/login")
    end
  end
end
