class InvitationRequestsController < ApplicationController

  helper HeroBackgroundHelper

  def create
    @invitation_request = InvitationRequest.new invitation_request_params
    if @invitation_request.save
      flash.notice = 'Thank you for your interest.'
      redirect_to root_path
    else
      render 'home/show'
    end
  end

  private def invitation_request_params
    params.require(:invitation_request).permit(:email, :how_found)
  end
  

  private def login_required?
    false
  end
  
end