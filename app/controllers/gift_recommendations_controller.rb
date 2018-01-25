class GiftRecommendationsController < ApplicationController

  include PjaxCarouselController

  before_action -> { @enable_chat = true }

  helper CarouselHelper

  before_action :load_profile
  before_action :load_recommendations
  before_action :include_enhanced_ecommerce_analytics

  def index
    current_user.update_attribute :last_viewed_profile_id, @profile.id
    @gift_recommendation_id = params[:gift_recommendation_id].try(:to_i)
    load_gift_recommendation
    load_gift_image
  end

  def show
    @gift_recommendation_id = params[:id].to_i
    load_gift_recommendation
    load_gift_image
    unless pjax_request?
      redirect_to giftee_gift_recommendations_path(@giftee_id, gift_recommendation_id: @gift_recommendation_id, carousel_page: @page)
    end
  end

  def image
    @gift_recommendation_id = params[:gift_recommendation_id].to_i
    @gift_image_id = params[:id].to_i
    load_gift_recommendation
    load_gift_image
    unless pjax_request?
      redirect_to giftee_gift_recommendations_path(@giftee_id, gift_recommendation_id: @gift_recommendation_id, carousel_page: @page)
    end
  end

  def more_recommendations
  end

  def load_more_recommendations
    @profile.has_viewed_initial_recommendations = true
    @profile.save
    redirect_to giftee_gift_recommendations_path(@giftee_id, carousel_page: @page+1)
  end

  private

  def next_index(current_index, size)
    n = current_index + 1
    n > size-1 ? 0 : n
  end

  def prev_index(current_index, size)
    n = current_index - 1
    n < 0 ? (size-1) : n
  end

  def load_gift_image
    if @gift.present?
      @gift_images = @gift.carousel_images
      if @gift_image_id.present?
        @gift_image = @gift_images.select{|i| i.id == @gift_image_id}.first || @gift_images.first
        @gift_image_index = @gift_images.index(@gift_image) || 0
      else
        @gift_image = @gift_images.first
        @gift_image_index = 0
      end
      @next_gift_image = @gift_images[next_index(@gift_image_index, @gift_images.size)]
      @prev_gift_image = @gift_images[prev_index(@gift_image_index, @gift_images.size)]
    end
  end

  def load_gift_recommendation
    @direction = params[:direction]
    gift_rec_size = @gift_recommendations.size
    if @gift_recommendations.any?
      if @gift_recommendation_id.present?
        @gift_recommendation = @gift_recommendations.select{ |gr| gr.id == @gift_recommendation_id }.first || @gift_recommendations.first
        @gift_index = @gift_recommendations.index(@gift_recommendation) || 0
      else
        @gift_recommendation = @gift_recommendations.first
        @gift_index = 0
      end
      @next_recommendation = @gift_recommendations[next_index(@gift_index, gift_rec_size)]
      @prev_recommendation = @gift_recommendations[prev_index(@gift_index, gift_rec_size)]
      @gift = @gift_recommendation.gift
    end
  end

  def load_profile
    giftee_id = params[:giftee_id] || session[:giftee_id]
    @giftee_id = giftee_id
    @profile = current_user.owned_profiles.find(giftee_id)
    session[:giftee_id] = @profile.id
  end

  def load_recommendations
    page_params = params[:carousel_page]&.to_i
    pages = GiftRecommendationSetPages.new(@profile, page_params)
    @total_pages = pages.page_count
    @page = pages.active_page
    @prev_page = pages.prev_page
    @next_page = pages.next_page
    @gift_recommendations = pages.page_recommendations
    if @gift_recommendations.any? && !impersonation_mode?
      GiftRecommendation.where(id: @gift_recommendations).update_all(viewed: true, viewed_at: Time.now)
    end
  end
end
