class CreateSurveySections < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_sections do |t|
      t.references :survey, foreign_key: true
      t.string :name
      t.integer :sort_order, null: false, default: 0

      t.timestamps
    end
  end
end
