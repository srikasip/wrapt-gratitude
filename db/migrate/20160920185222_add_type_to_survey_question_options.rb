class AddTypeToSurveyQuestionOptions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_question_options, :type, :string, index: true
  end
end
