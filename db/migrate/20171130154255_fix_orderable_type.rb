class FixOrderableType < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      UPDATE line_items
      set order_type = 'Ec::CustomerOrder'
      where order_type = 'CustomerOrder'
    SQL

    execute <<-SQL
      UPDATE line_items
      set order_type = 'Ec::PurchaseOrder'
      where order_type = 'PurchaseOrder'
    SQL

    execute <<-SQL
      UPDATE comments
      set commentable_type = 'Ec::CustomerOrder'
      where commentable_type = 'CustomerOrder'
    SQL

    execute <<-SQL
      UPDATE comments
      set commentable_type = 'Ec::PurchaseOrder'
      where commentable_type = 'PurchaseOrder'
    SQL
  end

  def down
    execute <<-SQL
      UPDATE line_items
      set order_type = 'CustomerOrder'
      where order_type = 'Ec::CustomerOrder'
    SQL

    execute <<-SQL
      UPDATE line_items
      set order_type = 'PurchaseOrder'
      where order_type = 'Ec::PurchaseOrder'
    SQL

    execute <<-SQL
      UPDATE comments
      set commentable_type = 'CustomerOrder'
      where commentable_type = 'Ec::CustomerOrder'
    SQL

    execute <<-SQL
      UPDATE comments
      set commentable_type = 'PurchaseOrder'
      where commentable_type = 'Ec::PurchaseOrder'
    SQL
  end
end
