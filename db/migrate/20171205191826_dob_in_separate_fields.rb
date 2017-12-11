class DobInSeparateFields < ActiveRecord::Migration[5.0]
  def up
    remove_column :profiles, :birthday
    add_column :profiles, :birthday_day, :integer
    add_column :profiles, :birthday_month, :integer
    add_column :profiles, :birthday_year, :integer
  end

  def down
    add_column :profiles, :birthday, :date
    remove_column :profiles, :birthday_day
    remove_column :profiles, :birthday_month
    remove_column :profiles, :birthday_year
  end
end
