class AddToggleAddressChoiceToCustomerOder < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_orders, :ship_to, :integer, default: 0
  end
end
