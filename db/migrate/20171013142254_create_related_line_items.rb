class CreateRelatedLineItems < ActiveRecord::Migration[5.0]
  def up
    create_table :related_line_items do |t|
      t.references :purchase_order, foreign_key: true, index: true, null: false
      t.references :customer_order, foreign_key: true, index: true, null: false
      t.integer :purchase_order_line_item_id, index: true, null: false
      t.integer :customer_order_line_item_id, index: true, null: false

      t.timestamps
    end

    execute("ALTER TABLE related_line_items ADD CONSTRAINT po_line_item_fk FOREIGN KEY (purchase_order_line_item_id) REFERENCES line_items (id);")
    execute("ALTER TABLE related_line_items ADD CONSTRAINT co_line_item_fk FOREIGN KEY (customer_order_line_item_id) REFERENCES line_items (id);")

    remove_column :line_items, :related_line_item_id
  end

  def down
    drop_table :related_line_items
    add_column :line_items, :related_line_item_id, :integer
  end
end
