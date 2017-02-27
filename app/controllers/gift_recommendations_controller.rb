class GiftRecommendationsController < ApplicationController

  GIFT_RECOMMENDATION_LIMIT = 10

  helper CarouselHelper

  before_action :load_profile
  before_action :load_recommendations
  
  def index
    current_user.update_attribute :last_viewed_profile_id, @profile.id
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def load_profile
    @profile = Profile.find(params[:profile_id])
  end

  def load_recommendations
    @gift_recommendations = @profile.gift_recommendations.limit(GIFT_RECOMMENDATION_LIMIT)
  end

end