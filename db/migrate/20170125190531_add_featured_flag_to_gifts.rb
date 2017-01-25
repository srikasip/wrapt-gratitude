class AddFeaturedFlagToGifts < ActiveRecord::Migration[5.0]
  def change
    add_column :gifts, :featured, :boolean, null: false, default: false
  end
end
