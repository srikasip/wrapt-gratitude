class GiftRecommendationsController < ApplicationController

  GIFT_RECOMMENDATION_LIMIT = 10

  helper CarouselHelper

  before_action :load_profile
  before_action :testing_redirect
  before_action :load_recommendations
  
  def index
    current_user.update_attribute :last_viewed_profile_id, @profile.id
  end

  private

  def load_profile
    profile_id = params[:profile_id] || session[:profile_id]
    @profile = current_user.owned_profiles.find(profile_id)
    session[:profile_id] = @profile.id
  end
  
  def testing_redirect
    if params[:profile_id].present? && current_user.unmoderated_testing_platform?
      # send them to pretty url for loop11 testing
      redirect_to testing_gift_recommendations_path
    end
  end

  def load_recommendations
    @gift_recommendations = @profile.gift_recommendations_with_limit(GIFT_RECOMMENDATION_LIMIT)
  end

end