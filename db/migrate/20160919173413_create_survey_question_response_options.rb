class CreateSurveyQuestionResponseOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_question_response_options do |t|
      t.references :survey_question_response, foreign_key: true, index: {name: :response_options_on_response_id}, null: false
      t.references :survey_question_option, foreign_key: true, index: {name: :response_options_on_option_id}, null: false

      t.timestamps
    end
  end
end
