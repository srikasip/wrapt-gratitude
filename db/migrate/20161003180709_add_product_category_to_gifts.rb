class AddProductCategoryToGifts < ActiveRecord::Migration[5.0]
  def change
    add_reference :gifts, :product_category, foreign_key: true
  end
end
