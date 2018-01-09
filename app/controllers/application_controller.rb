class ApplicationController < ActionController::Base
  protect_from_forgery with: :reset_session

  before_action :require_login, if: :login_required?
  before_action :set_signed_authentication_cookie
  before_action :load_notifications

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

  def load_notifications
    if current_user.present?
      gift_recommendation_set_ids = current_user.owned_profiles.unarchived.
        map do |profile|
          profile.most_recent_gift_recommendation_set.try(:id)
        end
      @my_giftee_notifications = current_user.gift_recommendation_notifications.
        where(gift_recommendation_set_id: gift_recommendation_set_ids).
        where(viewed: false).
        group_by(&:gift_recommendation_set)
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

end
