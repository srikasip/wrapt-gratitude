class AddStaleFlagToGiftRecommendationSets < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_recommendation_sets, :stale, :boolean, null: false, default: false
  end
end
