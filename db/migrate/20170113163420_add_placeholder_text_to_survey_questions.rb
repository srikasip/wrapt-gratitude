class AddPlaceholderTextToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :placeholder_text, :text
  end
end
