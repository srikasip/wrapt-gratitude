class ShippingInPurchaseOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :shipping_in_cents, :numeric
    add_column :purchase_orders, :shipping_cost_in_cents, :numeric
  end
end
