class PurchaseOrderStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :status, :string, default: 'initialized', null: false, index: true
  end
end
