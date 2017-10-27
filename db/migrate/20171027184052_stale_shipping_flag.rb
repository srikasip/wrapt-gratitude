class StaleShippingFlag < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_orders, :need_shipping_calculated, :boolean, default: true, null: false
  end
end
