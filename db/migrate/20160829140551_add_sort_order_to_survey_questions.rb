class AddSortOrderToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :sort_order, :integer, default: 0, null: false
  end
end
