class DefaultAutoCalulateGiftPriceAndCostToTrue < ActiveRecord::Migration[5.0]
  def change
    change_column :gifts, :calculate_cost_from_products, :boolean, default: true, null: false
    change_column :gifts, :calculate_price_from_products, :boolean, default: true, null: false
  end
end
