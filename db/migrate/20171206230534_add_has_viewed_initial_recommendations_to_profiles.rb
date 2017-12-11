class AddHasViewedInitialRecommendationsToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :has_viewed_initial_recommendations, :boolean, default: false, null: false
  end
end
