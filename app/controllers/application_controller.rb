class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # everything's admin only for now
  before_action :authenticate_user!
  before_action :require_admin!

  def require_admin!
    unless current_user.admin?
      flash[:alert] = "Sorry, you are not allowed to do that."
      redirect_to root_path
    end
  end
end
