class AddRangeLabelsToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :min_label, :string
    add_column :survey_questions, :max_label, :string
    add_column :survey_questions, :mid_label, :string
  end
end
