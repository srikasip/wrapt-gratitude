class AddConditionalQuestionIdToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :conditional_question_id, :integer, index: true
  end
end
