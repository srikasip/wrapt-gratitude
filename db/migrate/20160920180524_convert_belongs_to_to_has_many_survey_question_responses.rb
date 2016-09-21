class ConvertBelongsToToHasManySurveyQuestionResponses < ActiveRecord::Migration[5.0]
  def change
    SurveyQuestionResponse.all.each do |response|
      response.survey_question_option_ids = response.survey_question_option_id
      response.save!
    end
    remove_column :survey_question_responses, :survey_question_option_id

  end
end
