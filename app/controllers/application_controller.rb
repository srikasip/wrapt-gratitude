class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_login, if: :login_required?
  before_action :set_signed_authentication_cookie

  if Rails.env.production?
    before_filter :_basic_auth

    def _basic_auth
      authenticate_or_request_with_http_basic do |user, password|
        user == 'wrapt' && password == 'greenriver'
      end
    end
  end

  # TODO redefine in subclasses as needed
  def login_required?
    true
  end

  private def set_signed_authentication_cookie
    cookies.signed[:user_id] = current_user&.id
  end

end
