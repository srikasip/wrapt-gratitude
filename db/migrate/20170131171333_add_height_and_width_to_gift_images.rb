class AddHeightAndWidthToGiftImages < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_images, :width, :integer, null: false, default: 0
    add_column :gift_images, :height, :integer, null: false, default: 0
    add_column :product_images, :width, :integer, null: false, default: 0
    add_column :product_images, :height, :integer, null: false, default: 0
  end
end
