class AddSourceToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :source_vendor_id, :integer, index: true
  end
end
