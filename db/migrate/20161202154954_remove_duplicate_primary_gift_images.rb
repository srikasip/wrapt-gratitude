class RemoveDuplicatePrimaryGiftImages < ActiveRecord::Migration[5.0]
  def change
    Gift.preload(:gift_images, :primary_gift_image).each do |gift|
      if primary_image = gift.primary_gift_image
        gift.gift_images.update_all primary: false
        primary_image.update primary: true
      end
    end
  end
end
