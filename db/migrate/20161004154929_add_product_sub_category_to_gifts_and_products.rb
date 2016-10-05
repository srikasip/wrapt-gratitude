class AddProductSubCategoryToGiftsAndProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :product_subcategory_id, :integer, index: true
    add_column :gifts, :product_subcategory_id, :integer, index: true
  end
end
