class AddSurveyToSurveyResponses < ActiveRecord::Migration[5.0]
  def change
    add_reference :survey_responses, :survey, foreign_key: true
  end
end
