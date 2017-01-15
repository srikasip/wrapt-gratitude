class SurveyQuestionResponse < ApplicationRecord
  belongs_to :survey_response,
    inverse_of: :question_responses,
    polymorphic: true,
    touch: true
  belongs_to :survey_question

  has_many :survey_question_response_options, inverse_of: :survey_question_response, dependent: :destroy
  has_many :survey_question_options, through: :survey_question_response_options

  validates :text_response, presence: true, if: "survey_question.type == 'SurveyQuestions::Text'", on: :update

  def survey_question_option_id
    survey_question_option_ids.first
  end

  def survey_question_option_id= value
    self.survey_question_option_ids = [value]
  end

  def next_response
    this_index = survey_response.ordered_question_responses.to_a.index {|response| response.id == id}
    if this_index
      survey_response.ordered_question_responses[this_index + 1]
    end
  end

  def previous_response
    this_index = survey_response.ordered_question_responses.to_a.index {|response| response.id == id}
    if this_index&.> 0
      survey_response.ordered_question_responses[this_index - 1]
    end
  end

end