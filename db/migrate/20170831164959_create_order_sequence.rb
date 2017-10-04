class CreateOrderSequence < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE SEQUENCE internal_order_numbers
      INCREMENT BY 1
      MINVALUE #{InternalOrderNumber::RANGE.first}
      MAXVALUE #{InternalOrderNumber::RANGE.last}
    SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE internal_order_numbers
    SQL
  end
end
