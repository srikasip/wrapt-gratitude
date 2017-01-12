class PasswordReset
  include ActiveModel::Model

  attr_accessor :token, :password
  validates :password, presence: {message: 'You must choose a password.'}

  def persisted?
    true
  end

  def to_param
    token
  end

  def user
    @user ||= User.load_from_reset_password_token(token)
  end

  def save
    if valid?
      user.change_password! password
      return true
    else
      return false
    end
  end

end