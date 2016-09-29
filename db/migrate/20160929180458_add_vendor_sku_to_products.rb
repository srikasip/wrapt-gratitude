class AddVendorSkuToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :vendor_sku, :string
  end
end
