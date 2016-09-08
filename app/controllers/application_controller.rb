class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  
  before_action :require_private_access_session!
  # admin only by default
  # turn back on when we have real admin accounts @rrosen - 9/7/2016
  # before_action :authenticate_user!, unless: :devise_controller?
  # before_action :require_admin!, unless: :devise_controller?
  

  def require_admin!
    unless current_user&.admin?
      flash[:alert] = "Sorry, you are not allowed to do that."
      redirect_to root_path
    end
  end

  def require_private_access_session!
    unless session[:private_access_granted]
      redirect_to new_private_access_session_path
    end
  end

end
