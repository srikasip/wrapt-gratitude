class ProfileRecipientReviewsController < ApplicationController

  # TODO authenticate with access token

  GIFT_RECOMMENDATION_LIMIT = 10

  helper CarouselHelper
  helper GiftRecommendationsHelper

  def show
    @profile = Profile.find params[:profile_id]
    @gift_recommendations = @profile.gift_recommendations.limit(GIFT_RECOMMENDATION_LIMIT)

    @gift_dislikes = {}
    @gift_recommendations.each do |gr|
      @gift_dislikes[gr.id] = GiftDislike.new({gift: gr.gift})
    end
  end

end