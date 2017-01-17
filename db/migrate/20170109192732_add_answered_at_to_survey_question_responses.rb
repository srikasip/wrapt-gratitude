class AddAnsweredAtToSurveyQuestionResponses < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_question_responses, :answered_at, :datetime
  end
end
