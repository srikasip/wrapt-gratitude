class PurchaseOrderVendorToken < ActiveRecord::Migration[5.0]
  def change
    CustomerOrder.truncate(true) rescue ''

    add_column :purchase_orders, :vendor_token, :string, null: false
    add_index :purchase_orders, :vendor_token, unique: true

    add_column :purchase_orders, :vendor_acknowledgement_status, :string
    add_column :purchase_orders, :vendor_acknowledgement_reason, :string
  end
end
