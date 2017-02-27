require_relative '../../utilits/encrypt'
class User < Sequel::Model
  include Encrypt
  plugin :validation_helpers

  def validate
    validates_unique :email
    validates_format /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, :email
  end

  def self.create_new(data)
    user = self.new(:email => data['email'], :password => Encrypt.encrypt(data['password']))
    user.errors.add(:password, 'password is uncorrent') if /^[a-zA-Z0-9]{6,20}$/.match(data[:password]).nil?
    user
  end
end