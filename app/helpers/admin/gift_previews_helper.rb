module Admin
  module GiftPreviewsHelper

    def show_top_nav?
      false
    end
    
    def load_gift_carousel_data
      {
        nav_partial: 'gift_nav',
        slides: [
          {
            slide_partial: 'gift',
            slide_locals: {gift: @gift},
            thumbnail_partial: 'thumbnail',
            thumbnail_locals: {image: (@gift.primary_gift_image || @gift.gift_images.first)},
          }
        ]
      }
    end

    def load_gift_image_carousel_data(gift_images)
      images = gift_images.map do |gift_image|
        {
          slide_partial: 'gift_image',
          slide_locals: {image_url: gift_image.image_url(:large), image_orientation: gift_image.orientation},
          thumbnail_partial: 'gift_image_thumbnail',
          thumbnail_locals: {}
        }
      end
      {nav_partial: 'gift_image_nav', slides: images}
    end

  end
end