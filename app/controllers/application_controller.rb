class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_login, if: :login_required?
  before_action :set_signed_authentication_cookie

  # TODO redefine in subclasses as needed
  def login_required?
    true
  end

  private def set_signed_authentication_cookie
    cookies.signed[:user_id] = current_user&.id
  end

end
