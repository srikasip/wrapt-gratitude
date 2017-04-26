class UserActivationsMailer < ApplicationMailer

  def activation_needed_email user
    @user = user
    @activation_url = invitation_url(user.activation_token)

    mail to: user.email, subject: "Your invitation to try WRAPT" do |format|
      format.text do 
        if @user.unmoderated_testing_platform?
          render "activation_needed_unmoderated_testing_platform"
        else
          render 'activation_needed_email'
        end
      end
      format.html do
        if @user.unmoderated_testing_platform?
          render "activation_needed_unmoderated_testing_platform"
        else
          render 'activation_needed_email'
        end
      end
    end
  end

  def activation_success_email user
    @user = user

    mail to: user.email, subject: "Thank you for signing up for WRAPT!"
  end
end
