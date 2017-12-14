class PromoCodeRefinement < ActiveRecord::Migration[5.0]
  def up
    add_column :line_items, :taxable_total_price_in_dollars, :numeric
    remove_column :customer_orders, :pre_promo_total_to_charge_in_cents
    add_column :customer_orders, :promo_total_in_cents, :integer, default: 0
    add_column :customer_orders, :promo_free_subtotal_in_cents, :integer, default: 0

    execute <<-SQL
      UPDATE line_items set taxable_total_price_in_dollars = total_price_in_dollars
    SQL
  end

  def down
    remove_column :line_items, :taxable_total_price_in_dollars, :numeric
    remove_column :customer_orders, :promo_total_in_cents
    add_column :customer_orders, :pre_promo_total_to_charge_in_cents, :integer
    remove_column :customer_orders, :promo_free_subtotal_in_cents
  end
end
