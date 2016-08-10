class AddSecondaryPromptToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :secondary_prompt, :text
  end
end
