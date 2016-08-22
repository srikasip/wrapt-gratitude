class CreateEvaluationRecommendations < ActiveRecord::Migration[5.0]
  def change
    create_table :evaluation_recommendations do |t|
      t.references :survey_question_response, foreign_key: true
      t.references :product, foreign_key: true
      t.float :score
      t.references :training_set_evaluation, foreign_key: true

      t.timestamps
    end
  end
end
