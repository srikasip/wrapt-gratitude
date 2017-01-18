class GiftDislikesController < ApplicationController

  before_action :load_profile
  before_action :load_recommendation

  def create
    # TODO make this ajax
    @gift_dislike = GiftDislike.new(dislike_gift_params)
    @gift_dislike.profile = @profile
    @gift_dislike.gift = @gift
    @gift_dislike.save
    redirect_to profile_gift_recommendations_path(@profile)
  end

  private

  def load_profile
    @profile = Profile.find(params[:profile_id])
  end

  def load_recommendation
    @gift_recommendation = GiftRecommendation.find(params[:gift_recommendation_id])
    @gift = @gift_recommendation.gift
  end

  def dislike_gift_params
    params.require(:gift_dislike).permit(:reason)
  end

end