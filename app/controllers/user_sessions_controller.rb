class UserSessionsController < ApplicationController
  # Controller for login / logout

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new user_session_params.merge(controller: self)
    if login(@user_session.email, @user_session.password, @user_session.remember)
      flash.notice = 'You are now signed in.'
      redirect_back_or_to root_path
    else
      flash.alert = 'Email and password don\'t match'
      render :new
    end
  end

  def destroy
    logout
    flash.notice = 'You are now signed out.'
    redirect_to root_path
  end

  private def login_required?
    false
  end

  private def user_session_params
    params.require(:user_session).permit(
      :email,
      :password,
      :remember
    )
  end
  
  

end