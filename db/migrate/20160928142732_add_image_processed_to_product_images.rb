class AddImageProcessedToProductImages < ActiveRecord::Migration[5.0]
  def change
    add_column :product_images, :image_processed, :boolean, default: false, null: false
  end
end
