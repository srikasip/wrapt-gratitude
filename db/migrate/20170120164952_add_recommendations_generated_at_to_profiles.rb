class AddRecommendationsGeneratedAtToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :recommendations_generated_at, :datetime
  end
end
