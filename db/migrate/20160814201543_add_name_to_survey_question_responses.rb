class AddNameToSurveyQuestionResponses < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_question_responses, :name, :string
  end
end
