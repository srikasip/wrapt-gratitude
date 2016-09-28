class ProductImage < ApplicationRecord
  belongs_to :product
  mount_uploader :image, ProductImageUploader

  before_create :make_primary_if_only_product_image
  before_create :set_initial_sort_order

  after_save :enqueue_processing, if: :key, unless: :image_processed?

  private def make_primary_if_only_product_image
    if product.product_images.length <= 1
      self.primary = true
    end
  end

  private def set_initial_sort_order
    next_sort_order = ( product&.product_images.maximum(:sort_order) || 0 ) + 1
    self.sort_order = next_sort_order
  end

  private def enqueue_processing
    ProductImageProcessingJob.perform_later(self, key)
  end

end
