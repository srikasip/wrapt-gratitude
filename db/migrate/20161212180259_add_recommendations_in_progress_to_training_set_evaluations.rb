class AddRecommendationsInProgressToTrainingSetEvaluations < ActiveRecord::Migration[5.0]
  def change
    add_column :training_set_evaluations, :recommendations_in_progress, :boolean, default: false, null: false
  end
end
