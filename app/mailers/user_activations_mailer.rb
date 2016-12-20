class UserActivationsMailer < ApplicationMailer

  def activation_needed_email user
    @user = user
    @activation_url = sign_up_url(user.activation_token)

    mail to: user.email, subject: "You're invitation to try WRAPT"
  end

  def activation_success_email user
    @user = user

    mail to: user.email, subject: "Thanks for signing up for WRAPT!"
  end
end
