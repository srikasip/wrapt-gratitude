class AddSkuIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :products, :wrapt_sku
    add_index :gifts, :wrapt_sku
    add_index :vendors, :wrapt_sku_code
    add_index :product_categories, :wrapt_sku_code
  end
end
