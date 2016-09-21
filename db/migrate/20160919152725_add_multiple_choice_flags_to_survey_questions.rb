class AddMultipleChoiceFlagsToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    change_table :survey_questions do |t|
      t.boolean :multiple_option_responses, default: false, null: false
      t.boolean :include_other_option, default: false, null: false
    end
  end
end
