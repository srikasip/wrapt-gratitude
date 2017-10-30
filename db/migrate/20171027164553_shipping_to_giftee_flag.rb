class ShippingToGifteeFlag < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_orders, :shipping_to_giftee, :boolean, default: true, null: false
  end
end
