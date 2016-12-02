class GiftImage < ApplicationRecord
  belongs_to :gift, inverse_of: :gift_images

  before_create :make_primary_if_only_gift_image
  before_create :set_initial_sort_order

  private def make_primary_if_only_gift_image
    # gift.gift_images may or may not contain the current gift image
    # depending on how it was created
    if gift.gift_images.none?{|gift_image| gift_image != self }
      self.primary = true
    end
  end

  private def set_initial_sort_order
    next_sort_order = ( gift&.gift_images.maximum(:sort_order) || 0 ) + 1
    self.sort_order = next_sort_order
  end

  def to_partial_path
    'gift_images/gift_image'
  end


end
