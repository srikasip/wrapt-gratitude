class CreateGiftRecommendationNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :gift_recommendation_notifications do |t|
      t.integer :gift_recommendation_set_id
      t.integer :user_id
      t.boolean :viewed, null: false, default: false
      t.timestamps
    end
  end
end
