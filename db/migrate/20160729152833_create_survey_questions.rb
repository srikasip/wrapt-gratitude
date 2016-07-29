class CreateSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_questions do |t|
      t.references :survey, index: true, null: false
      t.text :prompt
      t.integer :position

      t.timestamps
    end
  end
end
