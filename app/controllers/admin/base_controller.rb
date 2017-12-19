module Admin
  class BaseController < ApplicationController

    layout 'admin'

    before_action :require_admin!

    def require_admin!
      unless current_user&.admin?
        flash[:alert] = "Sorry, you are not allowed to do that."
        redirect_to root_path
      end
    end
  end
end
