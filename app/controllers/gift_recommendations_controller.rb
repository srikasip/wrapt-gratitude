class GiftRecommendationsController < ApplicationController

  helper CarouselHelper

  before_action :load_profile
  before_action :load_recommendations
  
  def index
    @gift_dislikes = {}
    @gift_recommendations.each do |gr|
      @gift_dislikes[gr.id] = GiftDislike.new({gift: gr.gift})
    end
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
    @gift_recommendations = @profile.gift_recommendations
  end

end