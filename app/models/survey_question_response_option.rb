class SurveyQuestionResponseOption < ApplicationRecord
  belongs_to :survey_question_response
  belongs_to :survey_question_option
end
