class HomeController < ApplicationController

  helper HeroBackgroundHelper

  def show
    if current_user && current_user.last_viewed_profile.present? && !current_user.admin?
      redirect_to profile_gift_recommendations_path(current_user.last_viewed_profile) and return
    end

    unless current_user&.admin?
      @invitation_request = InvitationRequest.new
    end

  end

  private def login_required?
    false
  end

end