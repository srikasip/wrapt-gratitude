class AddRecommendationsGeneratedAtToSurveyResponse < ActiveRecord::Migration[5.0]
  def up
    add_column :survey_responses, :recommendations_generated_at, :datetime
    
    SurveyResponse.update_all("recommendations_generated_at = completed_at")
  end
  
  def down
    remove_column :survey_responses, :recommendations_generated_at
  end
end
