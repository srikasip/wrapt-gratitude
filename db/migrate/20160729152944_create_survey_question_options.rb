class CreateSurveyQuestionOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_question_options do |t|
      t.references :survey_question, index: true, null: false
      t.text :text
      t.string :image

      t.timestamps
    end
  end
end
