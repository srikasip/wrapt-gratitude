class MakeEvaluationRecommendationScoreNotNull < ActiveRecord::Migration[5.0]
  def change
    change_column :evaluation_recommendations, :score, :float, null: false, default: 0.0
  end
end
