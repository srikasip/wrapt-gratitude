class AddImageProcessedToGiftImage < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_images, :image_processed, :boolean, default: false, null: false
  end
end
