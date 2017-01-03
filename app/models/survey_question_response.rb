class SurveyQuestionResponse < ApplicationRecord
  belongs_to :survey_response,
    inverse_of: :question_responses,
    polymorphic: true,
    touch: true
  belongs_to :survey_question

  has_many :survey_question_response_options, inverse_of: :survey_question_response, dependent: :destroy
  has_many :survey_question_options, through: :survey_question_response_options

  def survey_question_option_id
    survey_question_option_ids.first
  end

  def survey_question_option_id= value
    self.survey_question_option_ids = [value]
  end

end