class AddSourceProductIdToGifts < ActiveRecord::Migration[5.0]
  def change
    add_column :gifts, :source_product_id, :integer, index: true
  end
end
