class AddVendorFieldsToProduct < ActiveRecord::Migration[5.0]
  def change
    change_table :products do |t|
      t.decimal :vendor_retail_price, precision: 10, scale: 2
      t.decimal :vendor_cost, precision: 10, scale: 2
      t.integer :units_available, null: false, default: 0
    end

  end
end
