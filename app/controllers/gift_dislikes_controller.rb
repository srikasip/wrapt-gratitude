class GiftDislikesController < ApplicationController

  before_action :load_profile
  before_action :load_recommendation

  def create
    @gift_dislike = GiftDislike.new(dislike_gift_params)
    @gift_dislike.profile = @profile
    @gift_dislike.gift = @gift
    respond_to do |format|
      if @gift_dislike.save && @gift_recommendation.present?
        format.js {render layout: false}
      else
        format.html { redirect_to profile_gift_recommendations_path(@profile) }
      end
    end
  end

  def destroy
    @gift_dislike = GiftDislike.where(profile: @profile, gift: @gift)
    @gift_dislike.destroy_all
    respond_to do |format|
      format.js {render layout: false}
    end
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