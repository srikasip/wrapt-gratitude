class AddCalculatePriceFromProductsToGifts < ActiveRecord::Migration[5.0]
  def change
    add_column :gifts, :calculate_price_from_products, :boolean, default: false, null: false
  end
end
