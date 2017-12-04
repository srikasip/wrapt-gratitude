class GiftRecommendationsController < ApplicationController
  
  include PjaxCarouselController

  before_action -> { @enable_chat = true }

  GIFT_RECOMMENDATION_LIMIT = 6

  helper CarouselHelper

  before_action :load_profile
  before_action :testing_redirect
  before_action :load_recommendations

  before_action :load_gift_recommendation, only: [:show, :image]

  def index
    current_user.update_attribute :last_viewed_profile_id, @profile.id
  end

  def show
    gift_rec_size = @gift_recommendations.size
    @index = @all_gift_recommendations.index(@gift_recommendation)
  
    @next_recommendation = @gift_recommendations[next_index(@index, gift_rec_size)]
    @prev_recommendation = @gift_recommendations[prev_index(@index, gift_rec_size)]
  end

  def image
    @parent_index = @all_gift_recommendations.index(@gift_recommendation)
    @gift_images = @gift.carousel_images
    @gift_image = @gift_images.select{|i| i.id.to_s == params[:id]}.first
    @index = @gift_images.index(@gift_image)
    @next_gift_image = @gift_images[next_index(@index, @gift_images.size)]
    @prev_gift_image = @gift_images[prev_index(@index, @gift_images.size)] 

    render layout: false
  end

  private

  def next_index(current_index, size)
    if current_index > size
      0
    else
      (current_index+1) > (size-1) ? 0 : (current_index+1)
    end
  end

  def prev_index(current_index, size)
    if current_index > size
      size-1
    else
      (current_index-1) < 0 ? (size-1) : (current_index-1)
    end
  end

  def load_gift_recommendation
    @giftee_id = params[:giftee_id]
    @max = GiftRecommendation.max
    @mobile_max = GiftRecommendation.max(mobile: true)
    if action_name == 'show'
      gr_id = params[:id]
    else
      gr_id = params[:gift_recommendation_id]
    end
    @direction = params[:direction]
    # @gift_recommendation = @gift_recommendations.select{|gr| gr.id.to_s == gr_id}.first
    @gift_recommendation = @profile.gift_recommendations.find(gr_id)
    @gift = @gift_recommendation.gift
  end

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
    @page = (params[:carousel_page] || 1)&.to_i
    @previous = params[:previous_page].try(:to_i)
    all_gift_recommendations = @profile.
       gift_recommendations.
       where(gift_id: Gift.select(:id).can_be_sold, removed_by_expert: false).
       preload(gift: [:gift_images, :primary_gift_image, :products, :product_subcategory, :calculated_gift_field])
    
    @total_pages = GiftRecommendation.pages(all_gift_recommendations)      
    @mobile_total_pages = GiftRecommendation.pages(all_gift_recommendations, mobile: true)
    if @previous.present?
      @indicators = GiftRecommendation.select_for_display(all_gift_recommendations, @previous)
    else
      @indicators = GiftRecommendation.select_for_display(all_gift_recommendations, @page)
    end
    @mobile_indicators = GiftRecommendation.select_for_display(all_gift_recommendations, @page, mobile: true)
    @all_gift_recommendations = GiftRecommendation.select_for_display(all_gift_recommendations, 'all')
    @gift_recommendations = GiftRecommendation.select_for_display(all_gift_recommendations, @page)
  end
end
