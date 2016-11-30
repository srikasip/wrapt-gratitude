class GiftProduct < ApplicationRecord
  belongs_to :gift, inverse_of: :gift_products, required: true
  belongs_to :product, inverse_of: :gift_products, required: true

  # Adding a product to a gift adds its images too
  after_create :create_gift_images_from_products

  # Removing a product from a gift removes its images
  before_destroy :destroy_gift_images_from_products

  private def create_gift_images_from_products
    product.gifts.each do |gift|
      product.product_images.each do |product_image|
        gift.gift_images_from_products.create product_image: product_image
      end
    end
  end

  private def destroy_gift_images_from_products
    GiftImages::FromProduct
      .where(gift_id: product.gifts.select(:id))
      .where(product_image_id: product.product_images.select(:id))
      .destroy_all
  end
  
end
