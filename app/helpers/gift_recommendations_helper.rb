module GiftRecommendationsHelper

  def load_gift_recommendation_carousel_data(gift_recommendations)
    gifts = gift_recommendations.preload(gift: [:gift_images, :primary_gift_image, :products]).map do |gr|
      {
        slide_partial: 'gift',
        slide_locals: {gift: gr.gift, gift_recommendation: gr},
        thumbnail_partial: 'thumbnail',
        thumbnail_locals: {image: (gr.gift.primary_gift_image || gr.gift.gift_images.first)},
      }
    end
    {nav_partial: 'gift_nav', slides: gifts}
  end

  def load_gift_image_carousel_data(gift_images)
    images = gift_images.map do |gift_image|
      {
        slide_partial: 'gift_image',
        slide_locals: {image_url: gift_image.image_url(:large)},
        thumbnail_partial: 'gift_image_thumbnail',
        thumbnail_locals: {}
      }
    end
    {nav_partial: 'gift_image_nav', slides: images}
  end

end