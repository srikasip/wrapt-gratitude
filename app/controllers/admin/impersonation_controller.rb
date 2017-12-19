module Admin
  class ImpersonationController < BaseController
    skip_before_action :require_admin!, only: [:deimpersonate]

    def impersonate
      admin_id = current_user.id
      user     =  User.find(params[:id])

      if !user.active?
        flash[:error] = "Sorry, but that user isn't active"
        redirect_back fallback_location: '/'
        return
      end

      logout
      auto_login(user)

      session[:was_admin] = admin_id

      flash[:notice] = "You are now impersonating #{user.full_name}"
      flash[:just_impersonated] = true

      redirect_to :root
    end

    def deimpersonate
      raise "ids didn't match" unless session[:was_admin].to_i == params[:id].to_i

      user = User.find(session[:was_admin])
      logout
      auto_login(user)

      flash[:notice] = "You are back to your own account now"
      redirect_to :root
    end
  end
end
