class DropGiftRecommendationNotifications < ActiveRecord::Migration[5.0]
  def change
    drop_table :gift_recommendation_notifications
  end
end
