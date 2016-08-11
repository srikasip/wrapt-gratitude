class ChangeResponseImpactImpactToFloat < ActiveRecord::Migration[5.0]
  def change
    change_column :training_set_response_impacts, :impact, :float, null: false, default: 0
  end
end
