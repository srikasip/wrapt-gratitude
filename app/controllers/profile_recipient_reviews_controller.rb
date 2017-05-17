class ProfileRecipientReviewsController < ApplicationController

  include AuthenticatesWithRecipientAccessToken

  helper CarouselHelper

  def show
    @gift_recommendations = @profile.gift_recommendations.preload(
      gift: [:gift_images, :primary_gift_image, :products, :product_subcategory, :calculated_gift_field])
    
    @profile.update_attribute :recipient_reviewed, true
  end

  private def profile_id_param
    params[:id]
  end
  

end