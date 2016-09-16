class AddSortOrderToGiftImages < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_images, :sort_order, :integer, default: 0, null: false
  end
end
