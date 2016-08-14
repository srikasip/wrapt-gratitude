class CreateProfileSets < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_sets do |t|
      t.string :name
      t.references :survey, foreign_key: true, index: true

      t.timestamps
    end
  end
end
