class AddWraptSkuToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :wrapt_sku, :string
  end
end
