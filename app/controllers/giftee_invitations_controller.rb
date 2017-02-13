class GifteeInvitationsController < ApplicationController

  include PjaxModalController

  before_action :set_profile

  def new
  end

  def create
    if @profile.update profile_params
      GifteeInvitationsMailer.review_gift_selections_invitation(@profile).deliver_later
      render :create
    else
      render :new
    end
  end

  
  private def set_profile
    @profile = current_user.owned_profiles.find params[:profile_id]
  end

  private def profile_params
    params.require(:profile).permit(:email)
  end
  
  
  

end