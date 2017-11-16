class GiftRecommendationsController < ApplicationController
  before_action -> { @enable_chat = true }

  GIFT_RECOMMENDATION_LIMIT = 6

  helper CarouselHelper

  before_action :load_profile
  before_action :testing_redirect
  before_action :load_recommendations

  def index
    current_user.update_attribute :last_viewed_profile_id, @profile.id
  end

  private

  def load_profile
    giftee_id = params[:giftee_id] || session[:giftee_id]
    @profile = current_user.owned_profiles.find(giftee_id)
    session[:giftee_id] = @profile.id
  end

  def testing_redirect
    if params[:giftee_id].present? && current_user.unmoderated_testing_platform?
      # send them to pretty url for loop11 testing
      redirect_to testing_gift_recommendations_path
    end
  end

  def load_recommendations
    @gift_recommendations = @profile.
       gift_recommendations.
       where(gift_id: Gift.select(:id).can_be_sold, removed_by_expert: false).
       preload(gift: [:gift_images, :primary_gift_image, :products, :product_subcategory, :calculated_gift_field]).
       take(GIFT_RECOMMENDATION_LIMIT)
  end
end
