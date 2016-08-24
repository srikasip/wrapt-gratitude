class RemoveSecondaryPromptFromSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    remove_column :survey_questions, :secondary_prompt
  end
end
