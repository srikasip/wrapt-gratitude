class RecipientOriginatedReferralsController < ApplicationController

  include AuthenticatesWithRecipientAccessToken
  include PjaxModalController

  def new
    @recipient_originated_referral = RecipientOriginatedReferral.new
  end

  def create
    @recipient_originated_referral = RecipientOriginatedReferral.new recipient_originated_referral_params
    if @recipient_originated_referral.save
      flash.notice = 'Thank you!'
      redirect_to profile_recipient_review_path(@profile.recipient_access_token)
    else
      render :new
    end
  end

  private def recipient_originated_referral_params
    params.require(:recipient_originated_referral).permit(:emails)
  end
    

end
