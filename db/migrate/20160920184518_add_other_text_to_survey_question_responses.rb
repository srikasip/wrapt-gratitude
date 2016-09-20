class AddOtherTextToSurveyQuestionResponses < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_question_responses, :other_option_text, :text
  end
end
