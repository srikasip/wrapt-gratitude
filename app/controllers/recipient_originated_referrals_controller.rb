class RecipientOriginatedReferralsController < ApplicationController

  include AuthenticatesWithRecipientAccessToken
  include PjaxModalController

  def new
    @recipient_originated_referral = RecipientOriginatedReferral.new
  end

  def create
    @recipient_originated_referral = RecipientOriginatedReferral.new recipient_originated_referral_params
    @recipient_originated_referral.profile = @profile
    if @recipient_originated_referral.save
      render :create
    else
      render :new
    end
  end

  private def recipient_originated_referral_params
    params.require(:recipient_originated_referral).permit(:emails)
  end
    

end
