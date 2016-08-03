class CreateTrainingSets < ActiveRecord::Migration[5.0]
  def change
    create_table :training_sets do |t|
      t.string :name
      t.references :survey, index: true
      
      t.timestamps
    end
  end
end
