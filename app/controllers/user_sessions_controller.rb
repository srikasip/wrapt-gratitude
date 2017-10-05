class UserSessionsController < ApplicationController
  # Controller for login / logout

  include PjaxModalController

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new user_session_params.merge(controller: self)
    if login(@user_session.email, @user_session.password, @user_session.remember)
      redirect_to params[:return_to] || default_location_for_user(user)
    else
      @user_session.errors.add :password, 'Sorry, that password isn\'t correct'
      render :new
    end
  end

  def destroy
    logout
    redirect_to root_path
  end

  private def login_required?
    false
  end

  private def default_location_for_user
    if user.last_viewed_profile.present?
      profile_gift_recommendations_path(user.last_viewed_profile)
    else
      root_path
    end
  end

  private def user_session_params
    params.require(:user_session).permit(
      :email,
      :password,
      :remember
    )
  end

end
