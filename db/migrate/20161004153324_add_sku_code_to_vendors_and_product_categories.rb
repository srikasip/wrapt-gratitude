class AddSkuCodeToVendorsAndProductCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :vendors, :wrapt_sku_code, :string
    add_column :product_categories, :wrapt_sku_code, :string
  end
end
