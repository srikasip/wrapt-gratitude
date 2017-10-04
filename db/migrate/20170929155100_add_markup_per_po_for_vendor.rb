class AddMarkupPerPoForVendor < ActiveRecord::Migration[5.0]
  def change
    add_column :vendors, :purchase_order_markup_in_cents, :integer, default: 800, null: false

    add_column :customer_orders, :handling_cost_in_cents, :integer, null: false, default: 0
    add_column :customer_orders, :handling_in_cents, :integer, null: false, default: 0

    add_column :purchase_orders, :handling_cost_in_cents, :integer, null: false, default: 0
    add_column :purchase_orders, :handling_in_cents, :integer, null: false, default: 0
  end
end
