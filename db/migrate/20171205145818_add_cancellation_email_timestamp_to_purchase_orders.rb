class AddCancellationEmailTimestampToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :cancellation_emails_sent_at, :datetime
  end
end
