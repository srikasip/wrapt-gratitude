class CreateSurveyQuestionResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_question_responses do |t|
      t.references :profile_set_survey_response, null: false, foreign_key: true, index: false
      t.references :survey_question, null: false, foreign_key: true
      t.text :text_response
      t.references :survey_question_option, foreign_key: true
      t.float :range_response

      t.timestamps
    end

    add_index :survey_question_responses, :profile_set_survey_response_id, name: 'index_question_response_on_survey_response_id'
  end
end
