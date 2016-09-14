class MakeGiftDateColumnsNotNull < ActiveRecord::Migration[5.0]
  def change
    change_column :gifts, :date_available, :date, null: false, default: Date.new(1900, 1, 1)
    change_column :gifts, :date_discontinued, :date, null: false, default: Date.new(2999, 12, 31)
  end
end
