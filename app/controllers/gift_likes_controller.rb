class GiftLikesController < ApplicationController
  before_action :load_profile
  helper GiftRecommendationsHelper

  layout 'xhr'

  def create
    @gift_like = @profile.gift_likes.new gift_like_params
    if @gift_like.save
      render 'gift_recommendations/_gift_like', locals: {gift: @gift_like.gift, profile: @profile}
    else
      head :bad_request
    end
  end

  def destroy
    @gift_like = @profile.gift_likes.find params[:id]
    @gift_like.destroy
    render 'gift_recommendations/_gift_like', locals: {gift: @gift_like.gift, profile: @profile}
  end

  private def gift_like_params
    params.require(:gift_like).permit(:gift_id, :reason)
  end

  private def load_profile
    @profile = Profile.find(params[:giftee_id])
  end

end
