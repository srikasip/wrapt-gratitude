class AddUseResponseAsRelationshipToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :use_response_as_relationship, :boolean, default: false, null: false
  end
end
