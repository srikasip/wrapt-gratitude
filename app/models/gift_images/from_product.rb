module GiftImages
  class FromProduct < GiftImage
    # This subclass represents image objects that have
    # been automatically synced from the products in the gift

    belongs_to :product_image, inverse_of: :gift_images_from_products
    
    delegate :image,
      :image?,
      :image_url,
      :image_processed?,
      to: :product_image


  end
end