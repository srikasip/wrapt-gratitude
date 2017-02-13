class GifteeInvitationsController < ApplicationController

  include PjaxModalController

  before_action :set_profile

  def new
  end

  def create
    flash.notice = 'Gift Selection Notification coming in a future Release'
    redirect_to root_path
  end

  
  private def set_profile
    @profile = current_user.owned_profiles.find params[:profile_id]
  end
  
  

end