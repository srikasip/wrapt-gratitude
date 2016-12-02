class SyncExistingGiftProductImages < ActiveRecord::Migration[5.0]
  def change
    GiftProduct.all.preload(product: [:product_images, :gifts]).each do |gift_product|
      gift_product.create_gift_images_from_products
    end
  end
end
