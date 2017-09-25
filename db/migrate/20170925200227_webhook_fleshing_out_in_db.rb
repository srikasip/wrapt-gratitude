class WebhookFleshingOutInDb < ActiveRecord::Migration[5.0]
  def change
    add_column :shipping_labels, :eta, :datetime
    add_column :shipping_labels, :tracking_status, :string
    add_column :shipping_labels, :tracking_updated_at, :datetime
    add_column :shipping_labels, :tracking_payload, :jsonb
  end
end
