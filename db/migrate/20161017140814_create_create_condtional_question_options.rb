class CreateCreateCondtionalQuestionOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :conditional_question_options do |t|
      t.references :survey_question, foreign_key: true
      t.references :survey_question_option, foreign_key: true

      t.timestamps
    end
  end
end
