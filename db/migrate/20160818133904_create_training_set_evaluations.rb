class CreateTrainingSetEvaluations < ActiveRecord::Migration[5.0]
  def change
    create_table :training_set_evaluations do |t|
      t.references :training_set, foreign_key: true

      t.timestamps
    end
  end
end
