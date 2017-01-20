class AddScoreToGiftRecommendations < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_recommendations, :score, :float, default: 0.0, null: false
  end
end
