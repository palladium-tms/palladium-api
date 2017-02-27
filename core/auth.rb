require_relative '../management'

module Auth
  def authenticate(email, password)
    current_user = User.find(:email => email)
    return false if current_user.nil?
    if Encrypt.encrypt(password) == current_user.password
      return true
    else
      return false
    end
  end

  def auth_success?(user_data)
    authenticate(user_data['email'], user_data['password'])
  end
end