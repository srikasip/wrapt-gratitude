class CancelShippingPossible < ActiveRecord::Migration[5.0]
  def change
    add_column :shipping_labels, :cancelled, :boolean, default: false, null: false
    rename_column :shipping_labels, :shippo_object_id, :shippo_rate_object_id
    add_column :shipping_labels, :refund_api_response, :jsonb
  end
end
