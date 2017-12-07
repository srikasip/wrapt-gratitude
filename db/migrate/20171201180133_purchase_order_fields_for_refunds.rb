class PurchaseOrderFieldsForRefunds < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :gift_amount_for_customer_in_cents, :integer, null: false, default: 0
    add_column :purchase_orders, :tax_amount_for_customer_in_cents, :integer, null: false, default: 0
  end
end
