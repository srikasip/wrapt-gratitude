class GiftRecommendationsController < ApplicationController
  
  include PjaxCarouselController

  before_action -> { @enable_chat = true }

  GIFT_RECOMMENDATION_LIMIT = 6

  helper CarouselHelper

  before_action :load_profile
  before_action :testing_redirect
  before_action :load_recommendations

  def index
    current_user.update_attribute :last_viewed_profile_id, @profile.id
    load_gift_recommendation
    load_gift_image
  end

  def show
    @gift_recommendation_id = params[:id].to_i
    load_gift_recommendation
    load_gift_image
  end

  def image
    @gift_recommendation_id = params[:gift_recommendation_id].to_i
    @gift_image_id = params[:id].to_i
    load_gift_recommendation
    load_gift_image 
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
        @gift_recommendation = @gift_recommendations.select{ |gr| gr.id == @gift_recommendation_id}.first || @gift_recommendations.first
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

  def testing_redirect
    if params[:giftee_id].present? && current_user.unmoderated_testing_platform?
      # send them to pretty url for loop11 testing
      redirect_to testing_gift_recommendations_path
    end
  end

  def load_pages(all_gift_recommendations)
    @total_pages = GiftRecommendation.pages(all_gift_recommendations)
    @page = (params[:carousel_page] || 1)&.to_i
    if @page == 0
      @page = 1
    elsif @page > @total_pages
      @page = @total_pages
    end
    @page = 1 if !@profile.has_viewed_initial_recommendations?
    @prev_page = @page <= 1 ? 1 : @page-1
    @next_page = @page >= @total_pages ? @total_pages : @page+1
  end

  def load_recommendations
    all_gift_recommendations = @profile.
       gift_recommendations.
       where(gift_id: Gift.select(:id).can_be_sold, removed_by_expert: false).
       preload(gift: [:gift_images, :primary_gift_image, :products, :product_subcategory, :calculated_gift_field])
    
    load_pages(all_gift_recommendations)
    @gift_recommendations = GiftRecommendation.select_for_display(all_gift_recommendations, @page)
  end
end
