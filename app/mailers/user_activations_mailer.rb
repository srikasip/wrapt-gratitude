class UserActivationsMailer < ApplicationMailer

  def activation_needed_email user
    @user = user
    @activation_url = invitation_url(user.activation_token)

    mail to: user.email, subject: "Your invitation to try WRAPT" do |format|
      format.text {render "activation_needed_unmoderated_testing_platform" if @user.unmoderated_testing_platform?}
      format.html {render "activation_needed_unmoderated_testing_platform" if @user.unmoderated_testing_platform?}
    end
  end

  def activation_success_email user
    @user = user

    mail to: user.email, subject: "Thank you for signing up for WRAPT!"
  end
end
