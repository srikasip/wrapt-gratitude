class ProductImage < ApplicationRecord
  belongs_to :product, inverse_of: :product_images
  mount_uploader :image, ProductImageUploader

  before_create :make_primary_if_only_product_image
  before_create :set_initial_sort_order
  # Adding a product image adds a gift image to all of the
  # product's gifts
  after_create :create_gift_images_from_products

  after_save :enqueue_processing, if: :key, unless: :image_processed?

  has_many :gift_images_from_products,
    class_name: 'GiftImages::FromProduct',
    inverse_of: :product_image,
    dependent: :destroy # deleting a product image deletes the linked gift images


  private def make_primary_if_only_product_image
    if product.product_images.none?{|product_image| product_image != self }
      self.primary = true
    end
  end

  private def set_initial_sort_order
    next_sort_order = ( product&.product_images.maximum(:sort_order) || 0 ) + 1
    self.sort_order = next_sort_order
  end

  private def enqueue_processing
    DirectUploadedImageProcessingJob.perform_later(self, key)
  end

  def image_owner
    product
  end

  def processing_channel_class
    ProductImageProcessingChannel
  end

  private def create_gift_images_from_products
    product.gifts.each do |gift|
      gift.gift_images_from_products.create product_image: self
    end
  end
  

end
