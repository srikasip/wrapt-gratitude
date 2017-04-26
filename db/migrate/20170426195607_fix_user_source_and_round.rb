class FixUserSourceAndRound < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :source, :string
    change_column :users, :beta_round, :string
  end
end
