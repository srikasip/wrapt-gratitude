module GiftRecommendationsHelper

  def load_gift_recommendation_carousel_gifts(gift_recommendations)
    gifts = gift_recommendations.map do |gr|
      {
        slide_partial: 'gift',
        slide_locals: {gift: gr.gift, gift_recommendation: gr},
        thumbnail_partial: 'thumbnail',
        thumbnail_locals: {image: (gr.gift.gift_images.where(primary: true).first || gr.gift.gift_images.first)}
      }
    end
  end

  def load_gift_image_carouse_images(gift_images)
    images = gift_images.map do |gift_image|
      {
        slide_partial: 'gift_image',
        slide_locals: {image_url: gift_image.image_url(:large)},
        thumbnail_partial: 'gift_image_thumbnail',
        thumbnail_locals: {}
      }
    end
  end

end