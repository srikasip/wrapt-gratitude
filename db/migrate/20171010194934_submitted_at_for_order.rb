class SubmittedAtForOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_orders, :submitted_on, :date, index: true
  end
end
