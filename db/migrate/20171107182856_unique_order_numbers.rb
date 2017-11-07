class UniqueOrderNumbers < ActiveRecord::Migration[5.0]
  def change
    add_index :customer_orders, :order_number, unique: true
    add_index :purchase_orders, :order_number, unique: true
  end
end
