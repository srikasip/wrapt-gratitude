class PasswordResetRequest
  include ActiveModel::Model

  attr_accessor :email

  def save
    if user = User.find_by_email(email)
      # binding.pry
      # TODO use deliver_later
      user.generate_reset_password_token!
      PasswordResetRequestsMailer.reset_password_email(user).deliver_later
      return true
    else
      errors.add :email, 'We could not find an account with that email address.'
      return false
    end
  end

end