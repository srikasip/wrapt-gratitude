class MoreGifteeFields < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :birthday, :date
    add_column :profiles, :gifts_sent, :integer, null: false, default: 0
  end
end
