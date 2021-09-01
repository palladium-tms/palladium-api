# frozen_string_literal: true

require 'bcrypt'
class User < Sequel::Model
  include BCrypt
  one_to_many :tokens
  one_to_one :invite
  one_to_one :user_setting
  plugin :validation_helpers

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def validate
    validates_unique :email, message: 'Email is already taken.'
    validates_format(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, :email, message: 'Email format error. Please, check email.')
  end

  def self.create_new(data)
    @user = User.new(email: data['email'])
    if /^[a-zA-Z0-9]{4,20}$/.match(data['password']).nil?
      @user.errors.add(:password, 'password is incorrect')
    else
      @user.password = data['password']
      @user.password.salt
      @user.save_changes if @user.valid?
      @user.user_setting = UserSetting.create
    end
    @user
  end

  def self.user_token?(email, token)
    !User[email: email].tokens.find do |current_token|
      current_token.token == token
    end.nil?
  end
end
