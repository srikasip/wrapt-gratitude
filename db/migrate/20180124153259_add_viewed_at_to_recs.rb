class AddViewedAtToRecs < ActiveRecord::Migration[5.0]
  def up
    add_column :gift_recommendations, :viewed_at, :datetime
    GiftRecommendation.where(viewed: true).update_all('viewed_at = updated_at')
  end
  
  def down
    remove_column :gift_recommendations, :viewed_at
  end
end
