class CreateTraitTrainingSetQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :trait_training_set_questions do |t|
      t.references :trait_training_set, foreign_key: true
      t.references :question
      t.references :facet

      t.timestamps
    end
    add_foreign_key :trait_training_set_questions, :survey_questions, column: :question_id
  end
end
