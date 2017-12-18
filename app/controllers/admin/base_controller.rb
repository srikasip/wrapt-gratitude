module Admin
  class BaseController < ApplicationController

    layout 'admin'

    before_action :require_admin!

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
