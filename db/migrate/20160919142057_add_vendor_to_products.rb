class AddVendorToProducts < ActiveRecord::Migration[5.0]
  def change
    add_reference :products, :vendor, foreign_key: true, index: true
  end
end
