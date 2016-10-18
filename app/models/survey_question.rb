class SurveyQuestion < ApplicationRecord
  # abstract base class for survey questions
  belongs_to :survey, inverse_of: :questions
  has_many :gift_question_impacts, dependent: :destroy

  # type-specific associations are on the base class for preloading
  has_many :options, -> {order :sort_order}, inverse_of: :question, dependent: :destroy, class_name: 'SurveyQuestionOption'

  has_many :survey_question_responses, dependent: :destroy

  belongs_to :conditional_question, class_name: 'SurveyQuestion', required: false
  has_many :conditional_question_options, inverse_of: :survey_question, dependent: :destroy

  TYPES = {
    'SurveyQuestions::MultipleChoice' => 'Multiple Choice',
    'SurveyQuestions::Range' => 'Slider',
    'SurveyQuestions::Text' => 'Free Text'
  }

  before_create :set_initial_sort_order

  attr_accessor :conditional_display
  after_initialize :set_conditional_display

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
    result = prompt
    if name_question = survey.name_question
      if name_response = survey_response.question_responses.where(survey_question: name_question).first&.text_response.presence
        result = prompt.gsub '<name>', name_response
      end
    end
    return result
  end

  private def set_conditional_display
    self.conditional_display = conditional_question_id?
  end

  def conditional_display= value
    @conditional_display = value
    unless value
      conditional_question = nil
      conditional_question_options = []
    end
  end

  def conditional_question_option_option_ids= ids
    # TODO tear down conditional question options and rebuild them from the passed ids
  end
  

end