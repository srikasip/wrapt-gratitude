class ChangeSurveyQuestionResponsesToPolymorphic < ActiveRecord::Migration[5.0]
  def change
    rename_column :survey_question_responses, :profile_set_survey_response_id, :survey_response_id
    add_column :survey_question_responses, :survey_response_type, :string
    SurveyQuestionResponse.all.update_all survey_response_type: 'ProfileSetSurveyResponse'
    change_column :survey_question_responses, :survey_response_type, :string, null: false
  end
end
