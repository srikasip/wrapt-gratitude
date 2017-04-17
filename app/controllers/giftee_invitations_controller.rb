class GifteeInvitationsController < ApplicationController

  include PjaxModalController

  before_action :set_profile

  def new
  end

  def create
    @profile.attributes = profile_params
    @profile.recipient_invited_at = Time.now
    if @profile.save
      GifteeInvitationsMailer.review_gift_selections_invitation(@profile).deliver_later
      if current_user.unmoderated_testing_platform?
        redirect_to funds_path
      else
        render :create
      end
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