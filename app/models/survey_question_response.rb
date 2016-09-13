class SurveyQuestionResponse < ApplicationRecord
  belongs_to :survey_response, inverse_of: :question_responses, class_name: 'ProfileSetSurveyResponse', foreign_key: :profile_set_survey_response_id
  belongs_to :survey_question

  belongs_to :survey_question_option, required: false
end