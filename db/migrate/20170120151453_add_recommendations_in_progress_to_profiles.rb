class AddRecommendationsInProgressToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :recommendations_in_progress, :boolean, default: false, null: false
  end
end
