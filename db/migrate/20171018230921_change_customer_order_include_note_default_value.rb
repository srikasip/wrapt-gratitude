class ChangeCustomerOrderIncludeNoteDefaultValue < ActiveRecord::Migration[5.0]
  def change
    change_column_default :customer_orders, :include_note, from: false, to: true
  end
end
