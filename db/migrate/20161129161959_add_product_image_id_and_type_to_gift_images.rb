class AddProductImageIdAndTypeToGiftImages < ActiveRecord::Migration[5.0]
  def change
    add_reference :gift_images, :product_image, foreign_key: true
    add_column :gift_images, :type, :string
  end
end
