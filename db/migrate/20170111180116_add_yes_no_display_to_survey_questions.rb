class AddYesNoDisplayToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :yes_no_display, :boolean, default: false, null: false
  end
end
