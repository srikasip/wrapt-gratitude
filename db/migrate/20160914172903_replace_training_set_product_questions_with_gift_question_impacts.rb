class ReplaceTrainingSetProductQuestionsWithGiftQuestionImpacts < ActiveRecord::Migration[5.0]
  def change
    drop_table :training_set_product_questions

    create_table :gift_question_impacts do |t|
      t.references :training_set, foreign_key: true, null: false
      t.references :product, foreign_key: true, null: false
      t.references :survey_question, foreign_key: true, null: false

      t.boolean  "range_impact_direct_correlation", default: true, null: false
      t.float    "question_impact",                 default: 0.0,  null: false

      t.timestamps
    end
  end
end
