class CreateTraitResponseImpacts < ActiveRecord::Migration[5.0]
  def change
    create_table :trait_response_impacts do |t|
      t.references :trait_training_set_question, foreign_key: true
      t.references :survey_question_option, foreign_key: true
      t.integer :range_position

      t.timestamps
    end
  end
end
