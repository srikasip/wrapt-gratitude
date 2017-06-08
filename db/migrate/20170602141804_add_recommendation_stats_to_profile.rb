class AddRecommendationStatsToProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :recommendation_stats, :text
  end
end
