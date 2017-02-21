class GiftDislikesController < ApplicationController

  before_action :load_profile
  helper GiftRecommendationsHelper

  layout 'xhr'

  def create
    @gift_dislike = @profile.gift_dislikes.new gift_dislike_params
    if @gift_dislike.save
      render 'gift_recommendations/_gift_dislike', locals: {gift: @gift_dislike.gift, profile: @profile}
    else
      head :bad_request
    end
  end

  def destroy
    @gift_dislike = @profile.gift_dislikes.find params[:id]
    @gift_dislike.destroy
    render 'gift_recommendations/_gift_dislike', locals: {gift: @gift_dislike.gift, profile: @profile}
  end

  private def gift_dislike_params
    params.require(:gift_dislike).permit(:gift_id, :reason)
  end

  private def load_profile
    @profile = Profile.find(params[:profile_id])
  end

end