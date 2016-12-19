class PasswordResetRequestsController < ApplicationController
  # Drives the page for requesting a password reset

  def new
    @password_reset_request = PasswordResetRequest.new
  end

  def create
    @password_reset_request = PasswordResetRequest.new password_reset_request_params
    if @password_reset_request.save
      flash.notice = "We've emailed you instructions for resetting your password."
      redirect_to root_path
    else
      render :new
    end
  end

  private def login_required?
    false
  end

  private def password_reset_request_params
    params.require(:password_reset_request).permit(:email)
  end
  
  
  
end