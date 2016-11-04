class AddMatchingInProgressToSurveyResponseTraitEvaluations < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_response_trait_evaluations, :matching_in_progress, :boolean, default: false, null: false
  end
end
