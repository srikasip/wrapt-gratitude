class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  
  before_action :require_private_access_session!


  if Rails.env.production?
    before_filter :_basic_auth

    def _basic_auth
      authenticate_or_request_with_http_basic do |user, password|
        user == 'wrapt' && password == 'greenriver'
      end
    end
  end



  def require_private_access_session!
    unless session[:private_access_granted]
      redirect_to new_private_access_session_path
    end
  end

end
