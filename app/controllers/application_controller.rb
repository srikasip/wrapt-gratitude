class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_login, if: :login_required?
  before_action :set_signed_authentication_cookie

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
