class ProfileRecipientReviewsController < ApplicationController

  # TODO authenticate with access token
  before_action :load_profile_from_access_token

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

  def login_required?
    false
  end

  def load_profile_from_access_token
    unless @profile = Profile.find_by_recipient_access_token params[:id]
      flash.alert = 'Sorry, that link is not valid.'
      redirect_to root_path
    end
  end

end