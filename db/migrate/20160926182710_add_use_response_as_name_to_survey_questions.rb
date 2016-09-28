class AddUseResponseAsNameToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :use_response_as_name, :boolean, default: false, null: false, index: true
  end
end
