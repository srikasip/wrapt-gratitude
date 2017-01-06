class PasswordResetsController < ApplicationController

  include PjaxModalController
  
  def show
    @password_reset = PasswordReset.new token: params[:id]
    not_authenticated unless @password_reset.user.present?
  end

  def update
    @password_reset = PasswordReset.new password_reset_params.merge(token: params[:id])
    not_authenticated and return unless @password_reset.user.present?
    if @password_reset.save
      auto_login(@password_reset.user)
      flash.notice = "We've reset your password and signed you in."
      redirect_to root_path
    else
      render :show
    end
  end

  private def login_required?
    false
  end

  private def password_reset_params
    params.require(:password_reset).permit(:password)
  end
  

end