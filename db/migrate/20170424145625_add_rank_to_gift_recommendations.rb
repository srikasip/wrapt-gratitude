class AddRankToGiftRecommendations < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_recommendations, :position, :integer, default: 0
    add_column :evaluation_recommendations, :position, :integer, default: 0
  end
end
