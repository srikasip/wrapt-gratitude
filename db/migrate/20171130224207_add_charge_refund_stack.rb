class AddChargeRefundStack < ActiveRecord::Migration[5.0]
  def change
    add_column :charges, :refund_stack, :jsonb
  end
end
