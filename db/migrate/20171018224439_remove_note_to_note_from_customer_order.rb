class RemoveNoteToNoteFromCustomerOrder < ActiveRecord::Migration[5.0]
  def change
    remove_column :customer_orders, :note_to
    remove_column :customer_orders, :note_from
  end
end
