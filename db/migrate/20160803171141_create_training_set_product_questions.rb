class CreateTrainingSetProductQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :training_set_product_questions do |t|
      t.references :training_set, foreign_key: true, null: false
      t.references :product, foreign_key: true, null: false
      t.references :survey_question, foreign_key: true, null: false

      t.timestamps
    end
  end
end
