class AddGiftRecommendationToGiftRecommendationNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_recommendation_notifications, :gift_recommendation_id, :integer
  end
end
