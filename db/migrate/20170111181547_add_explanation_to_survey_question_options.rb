class AddExplanationToSurveyQuestionOptions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_question_options, :explanation, :text
  end
end
