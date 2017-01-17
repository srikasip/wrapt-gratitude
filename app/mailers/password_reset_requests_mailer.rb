class PasswordResetRequestsMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.password_reset_requests_mailer.reset_password_email.subject
  #
  def reset_password_email(user)
    @user = user
    @reset_password_url = root_url(password_reset_token: user.reset_password_token)
    mail(:to => user.email,
         :subject => "Reset your Wrapt password")
  end
end
