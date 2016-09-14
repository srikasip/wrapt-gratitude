class EvaluationRecommendationsReferenceGifts < ActiveRecord::Migration[5.0]
  def change
    EvaluationRecommendation.delete_all
    TrainingSetEvaluation.delete_all # so we be sure to regenerate them
    remove_column :evaluation_recommendations, :product_id
    change_table :evaluation_recommendations do |t|
      t.references :gift, foreign_key: true, null: false
    end

  end
end
