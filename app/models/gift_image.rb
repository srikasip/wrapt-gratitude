class GiftImage < ApplicationRecord
  belongs_to :gift
  mount_uploader :image, ProductImageUploader

  before_create :make_primary_if_only_gift_image

  private def make_primary_if_only_gift_image
    if gift.gift_images.length <= 1
      self.primary = true
    end
  end
  

end
