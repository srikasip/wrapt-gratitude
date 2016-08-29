class AddSortOrderToSurveyQuestionOptions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_question_options, :sort_order, :integer, default: 0, null: false
  end
end
