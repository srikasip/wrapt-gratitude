class RenameProductsVendorCostToWraptCost < ActiveRecord::Migration[5.0]
  def change
    rename_column :products, :vendor_cost, :wrapt_cost
  end
end
