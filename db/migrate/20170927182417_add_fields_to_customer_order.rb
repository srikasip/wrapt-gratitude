class AddFieldsToCustomerOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_orders, :gift_wrapt, :boolean, default: true, null: false
    add_column :customer_orders, :include_note, :boolean, default: false, null: false
    add_column :customer_orders, :note_from, :string
    add_column :customer_orders, :note_to, :string
    add_column :customer_orders, :note_content, :text
  end
end
