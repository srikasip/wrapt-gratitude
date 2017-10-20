class AddAddressToCustomerOrder < ActiveRecord::Migration[5.0]
  def change
    add_reference :customer_orders, :address
  end
end
