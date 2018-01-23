class SurveyQuestionResponseOption < ApplicationRecord
  belongs_to :survey_question_response
  belongs_to :survey_question_option

  def copy_attributes
    {survey_question_option_id: survey_question_option_id}
  end
end
