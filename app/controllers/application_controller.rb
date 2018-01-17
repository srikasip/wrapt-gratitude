class ApplicationController < ActionController::Base
  protect_from_forgery with: :reset_session

  before_action :require_login, if: :login_required?
  before_action :set_signed_authentication_cookie

  helper :feature_flags

  if ENV['BASIC_AUTH_USERNAME'].present? && ENV['BASIC_AUTH_PASSWORD'].present?
    before_action :_basic_auth

    def _basic_auth
      authenticate_or_request_with_http_basic do |user, password|
        user == ENV['BASIC_AUTH_USERNAME'] && password == ENV['BASIC_AUTH_PASSWORD']
      end
    end
  end

  unless Rails.env.development?
    rescue_from Exception do |exception|
      ExceptionNotifier.notify_exception(exception,
        env: request.env,
        data: {:message => "was doing something wrong"}
      )

      render 'static_pages/page_500'
    end
  end

  # TODO redefine in subclasses as needed
  def login_required?
    true
  end

  def loop11_enabled?
    false
  end
  helper_method :loop11_enabled?

  private def set_signed_authentication_cookie
    cookies.signed[:user_id] = current_user&.id
  end

  def include_enhanced_ecommerce_analytics
    @include_enhanced_ecommerce_analytics = true
  end
  
  def impersonation_mode?
    session[:was_admin].present?
  end
  helper_method :impersonation_mode?
  
  def real_user
    if impersonating?
      @_real_user ||= User.find(session[:was_admin])
    else
      current_user
    end
  end
  helper_method :real_user

end
