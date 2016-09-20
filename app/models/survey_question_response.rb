class SurveyQuestionResponse < ApplicationRecord
  belongs_to :survey_response, inverse_of: :question_responses, class_name: 'ProfileSetSurveyResponse', foreign_key: :profile_set_survey_response_id
  belongs_to :survey_question

  has_many :survey_question_response_options, inverse_of: :survey_question_response, dependent: :destroy
  has_many :survey_question_options, through: :survey_question_response_options

end