class MoreCustomerOrderPromoFields < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_orders, :pre_promo_total_to_charge_in_cents, :integer
    add_column :customer_orders, :promo_delta_in_cents, :integer, default: 0, null: false
  end
end
