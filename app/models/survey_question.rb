class SurveyQuestion < ApplicationRecord
  # abstract base class for survey questions
  belongs_to :survey, inverse_of: :questions
  has_many :gift_question_impacts, dependent: :destroy

  # type-specific associations are on the base class for preloading
  has_many :options, -> {order :sort_order}, inverse_of: :question, dependent: :destroy, class_name: 'SurveyQuestionOption'

  has_many :survey_question_responses, dependent: :destroy

  TYPES = {
    'SurveyQuestions::MultipleChoice' => 'Multiple Choice',
    'SurveyQuestions::Range' => 'Slider',
    'SurveyQuestions::Text' => 'Free Text'
  }

  before_create :set_initial_sort_order

  def type_label
    raise "Abstract Method"
  end
  
  def system_type_label
    type_label.underscore.gsub(" ", "_")
  end

  private def set_initial_sort_order
    next_sort_order = ( survey&.questions.maximum(:sort_order) || 0 ) + 1
    self.sort_order = next_sort_order
  end

  def prompt_with_name survey_response
    if name_question = survey.name_question
      if name_response = survey_response.question_responses.where(survey_question: name_question).first&.text_response.presence
        prompt.gsub '<name>', name_response
      end
    end
  end

end