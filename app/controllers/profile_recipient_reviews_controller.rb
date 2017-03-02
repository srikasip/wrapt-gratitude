class ProfileRecipientReviewsController < ApplicationController

  include AuthenticatesWithRecipientAccessToken

  GIFT_RECOMMENDATION_LIMIT = 10

  helper CarouselHelper

  def show
    @gift_recommendations = @profile.gift_recommendations_with_limit(GIFT_RECOMMENDATION_LIMIT)
    @profile.update_attribute :recipient_reviewed, true
  end

  private def profile_id_param
    params[:id]
  end
  

end