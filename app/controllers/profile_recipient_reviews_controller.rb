class ProfileRecipientReviewsController < ApplicationController

  include AuthenticatesWithRecipientAccessToken

  GIFT_RECOMMENDATION_LIMIT = 10

  helper CarouselHelper
  helper GiftRecommendationsHelper

  def show
    @gift_recommendations = @profile.gift_recommendations.limit(GIFT_RECOMMENDATION_LIMIT)

    @gift_dislikes = {}
    @gift_recommendations.each do |gr|
      @gift_dislikes[gr.id] = GiftDislike.new({gift: gr.gift})
    end
  end

  private def profile_id_param
    params[:id]
  end
  

end