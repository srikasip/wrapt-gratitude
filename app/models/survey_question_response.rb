class SurveyQuestionResponse < ApplicationRecord
  belongs_to :survey_response, inverse_of: :question_responses, class_name: 'ProfileSetSurveyResponse'
  belongs_to :survey_question

  belongs_to :survey_question_option, required: false
end