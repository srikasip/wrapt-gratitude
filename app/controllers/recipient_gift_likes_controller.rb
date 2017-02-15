class RecipientGiftLikesController
  
  include AuthenticatesWithRecipientAccessToken

  def create
    @recipient_gift_like = @profile.recipient_gift_likes.new recipient_gift_like_params
    if @recipient_gift_like.save
      render 'profile_recipient_reviews/_gift_like', gift: @recipient_gift_like.gift, profile: @profile
    else
      head :bad_request
    end
  end

  def destroy
    @recipient_gift_like = @profile.recipient_gift_likes.find params[:id]
    @recipient_gift_like.destroy
    render 'profile_recipient_reviews/_gift_like', gift: @recipient_gift_like.gift, profile: @profile
  end
    
    

end