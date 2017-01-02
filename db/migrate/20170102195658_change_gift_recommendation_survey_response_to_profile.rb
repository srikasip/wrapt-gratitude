class ChangeGiftRecommendationSurveyResponseToProfile < ActiveRecord::Migration[5.0]
  def change
    remove_column :gift_recommendations, :survey_response_id
    add_reference :gift_recommendations, :profile, foreign_key: true
  end
end
