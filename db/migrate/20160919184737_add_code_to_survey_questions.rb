class AddCodeToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :code, :string
  end
end
