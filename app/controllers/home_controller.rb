class HomeController < ApplicationController

  def show
    if current_user && current_user.last_viewed_profile.present?
      redirect_to profile_gift_recommendations_path(current_user.last_viewed_profile)
    end
  end

  private def login_required?
    false
  end
  

end
