class AddPrimaryToGiftImage < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_images, :primary, :boolean, default: false, null: false
    add_index :gift_images, :primary
  end
end
