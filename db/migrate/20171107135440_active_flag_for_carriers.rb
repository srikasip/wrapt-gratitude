class ActiveFlagForCarriers < ActiveRecord::Migration[5.0]
  def change
    add_column :shipping_carriers, :active, :boolean, default: true, null: false
    # did this in two different branches:
    #add_column :shipping_service_levels, :active, :boolean, default: true, null: false
    add_reference :purchase_orders, :shipping_carrier, foreign_key: true
    add_reference :purchase_orders, :shipping_service_level, foreign_key: true
  end
end
