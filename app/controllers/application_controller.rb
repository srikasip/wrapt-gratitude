class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_login, if: :login_required?
  before_action :set_signed_authentication_cookie

  if ENV['BASIC_AUTH_USERNAME'].present? && ENV['BASIC_AUTH_PASSWORD'].present?
    before_action :_basic_auth

    def _basic_auth
      authenticate_or_request_with_http_basic do |user, password|
        user == ENV['BASIC_AUTH_USERNAME'] && password == ENV['BASIC_AUTH_PASSWORD']
      end
    end
  end

  rescue_from Exception do |exception|
    ExceptionNotifier.notify_exception(exception,
      env: request.env,
      data: {:message => "was doing something wrong"}
    )

    render 'static_pages/page_500'
  end

  # TODO redefine in subclasses as needed
  def login_required?
    true
  end

  def admin_login_required?
    false
  end
  helper_method :admin_login_required?

  def loop11_enabled?
    !admin_login_required?
  end
  helper_method :loop11_enabled?

  private def set_signed_authentication_cookie
    cookies.signed[:user_id] = current_user&.id
  end

end
