class ChangeSurveyResponsesUserToProfile < ActiveRecord::Migration[5.0]
  def change
    remove_column :survey_responses, :user_id
    add_reference :survey_responses, :profile, foreign_key: true
  end
end
