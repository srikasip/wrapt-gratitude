class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_login!, if: :login_required?

  if Rails.env.production?
    before_filter :_basic_auth

    def _basic_auth
      authenticate_or_request_with_http_basic do |user, password|
        user == 'wrapt' && password == 'greenriver'
      end
    end
  end

  def require_login!
    unless current_user
      redirect_to new_user_session_path
    end
  end

  def login_required?
    !devise_controller?
  end

end
