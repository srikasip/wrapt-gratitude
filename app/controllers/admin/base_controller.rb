module Admin
  class BaseController < ApplicationController

    layout 'admin'
    
    # turn back on when we have real admin accounts @rrosen - 9/7/2016
    # before_action :authenticate_user!, unless: :devise_controller?
    # before_action :require_admin!, unless: :devise_controller?


    def admin_login_required?
      true
    end

    def require_admin!
      unless current_user&.admin?
        flash[:alert] = "Sorry, you are not allowed to do that."
        redirect_to root_path
      end
    end
    
  end
end