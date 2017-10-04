class MoreShippingLabelData < ActiveRecord::Migration[5.0]
  def change
    CustomerOrder.destroy_all
    add_column :shipping_labels, :carrier, :string, null: false
    add_column :shipping_labels, :service_level, :string, null: false
  end
end
