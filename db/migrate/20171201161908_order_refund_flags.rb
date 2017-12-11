class OrderRefundFlags < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :customer_refunded_at, :datetime
  end
end
