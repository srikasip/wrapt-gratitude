class TimestampsForShippingLabels < ActiveRecord::Migration[5.0]
  def change
    add_column :shipping_labels, :shipped_on, :date
    add_column :shipping_labels, :delivered_on, :date
  end
end
