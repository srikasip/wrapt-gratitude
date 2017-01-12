class CreateGiftRecommendations < ActiveRecord::Migration[5.0]
  def change
    create_table :gift_recommendations do |t|
      t.references :survey_response, foreign_key: true
      t.references :gift, foreign_key: true

      t.timestamps
    end
  end
end
