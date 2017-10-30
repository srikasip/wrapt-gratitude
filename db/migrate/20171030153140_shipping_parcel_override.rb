class ShippingParcelOverride < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :shipping_parcel_id, :integer
  end
end
