class AddExpertAttributesToGiftRecs < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :expert_id, :integer
    add_column :gift_recommendations, :expert_score, :float, default: 0.0, null: false
    add_column :gift_recommendations, :removed_by_expert, :boolean, default: false, null: false
    add_column :gift_recommendations, :added_by_expert, :boolean, default: false, null: false
  end
end
