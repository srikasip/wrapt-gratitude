class RemoveSurveyQuestionResponseForeignKey < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :survey_question_responses, column: :survey_response_id
  end
end
