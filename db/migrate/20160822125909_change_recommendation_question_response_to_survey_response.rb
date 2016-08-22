class ChangeRecommendationQuestionResponseToSurveyResponse < ActiveRecord::Migration[5.0]
  def change
    remove_column :evaluation_recommendations, :survey_question_response_id
    change_table :evaluation_recommendations do |t|
      t.references :profile_set_survey_response, foreign_key: true, index: {name: 'eval_rec_survey_response'}
    end
  end
end
