class AddTypeToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :type, :string
  end
end
