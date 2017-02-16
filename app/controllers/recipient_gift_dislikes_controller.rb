class RecipientGiftDislikesController < ApplicationController
  
  include AuthenticatesWithRecipientAccessToken
  helper ProfileRecipientReviewsHelper

  layout 'xhr'

  def create
    @recipient_gift_dislike = @profile.recipient_gift_dislikes.new recipient_gift_dislike_params
    if @recipient_gift_dislike.save
      render 'profile_recipient_reviews/_gift_dislike', locals: {gift: @recipient_gift_dislike.gift, profile: @profile}
    else
      head :bad_request
    end
  end

  def destroy
    @recipient_gift_dislike = @profile.recipient_gift_dislikes.find params[:id]
    @recipient_gift_dislike.destroy
    render 'profile_recipient_reviews/_gift_dislike', locals: {gift: @recipient_gift_dislike.gift, profile: @profile}
  end

  private def recipient_gift_dislike_params
    params.require(:recipient_gift_dislike).permit(:gift_id, :reason)
  end
    

end