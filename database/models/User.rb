require_relative '../../utilits/encrypt'
class User < Sequel::Model
  include Encrypt
  one_to_many :tokens
  plugin :validation_helpers

  def validate
    validates_unique :email, message: 'Email is already taken.'
    validates_format /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, :email, message: 'Email format error. Please, check email.'
  end

  def self.create_new(data)
    user = new(email: data['email'], password: Encrypt.encrypt(data['password']))
    user.errors.add(:password, 'password is uncorrent') if /^[a-zA-Z0-9]{6,20}$/.match(data[:password]).nil?
    user
  end

  def self.user_token?(email, token)
    !User[email: email].tokens.find {|current_token|
      current_token.token == token
    }.nil?
  end
end
