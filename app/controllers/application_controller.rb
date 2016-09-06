class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # everything's admin only for now
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :require_admin!, unless: :devise_controller?

  if Rails.env.production?
    before_filter :_basic_auth

    def _basic_auth
      authenticate_or_request_with_http_basic do |user, password|
        user == 'wrapt' && password == 'greenriver'
      end
    end
  end

  def require_admin!
    unless current_user&.admin?
      flash[:alert] = "Sorry, you are not allowed to do that."
      redirect_to root_path
    end
  end
end
