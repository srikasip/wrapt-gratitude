class AddPromoToCustomerOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_orders, :promo_code, :string
    add_column :customer_orders, :promo_code_mode, :string
    add_column :customer_orders, :promo_code_amount, :integer
  end
end
