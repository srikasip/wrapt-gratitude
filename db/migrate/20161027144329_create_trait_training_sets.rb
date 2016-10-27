class CreateTraitTrainingSets < ActiveRecord::Migration[5.0]
  def change
    create_table :trait_training_sets do |t|
      t.string :name
      t.references :survey, foreign_key: true

      t.timestamps
    end
  end
end
