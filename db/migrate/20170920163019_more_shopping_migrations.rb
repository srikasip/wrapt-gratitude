class MoreShoppingMigrations < ActiveRecord::Migration[5.0]
  def change
    add_reference :shipping_labels, :purchase_order, foreign_key: true, null: false
    add_reference :shipping_labels, :customer_order, foreign_key: true, null: false
    add_column :shipping_labels, :tracking_url, :string
    add_column :line_items, :related_line_item_id, :integer
    add_column :purchase_orders, :order_number, :string, null: false
    add_column :purchase_orders, :created_on, :date, null: false
    add_column :purchase_orders, :total_due_in_cents, :numeric
    add_column :vendors, :street2, :string
    add_column :vendors, :street3, :string
  end
end
