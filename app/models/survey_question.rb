class SurveyQuestion < ApplicationRecord
  # abstract base class for survey questions
  belongs_to :survey, inverse_of: :questions
  has_many :training_set_product_questions, dependent: :destroy

  # type-specific associations are on the base class for preloading
  has_many :options, inverse_of: :question, dependent: :destroy, class_name: 'SurveyQuestionOption'

  has_many :survey_question_responses, dependent: :destroy

  TYPES = {
    'SurveyQuestions::MultipleChoice' => 'Multiple Choice',
    'SurveyQuestions::Range' => 'Slider',
    'SurveyQuestions::Text' => 'Free Text'
  }

  before_create :set_initial_sort_order

  def use_secondary_prompt?
    true
  end

  def type_label
    raise "Abstract Method"
  end
  
  def system_type_label
    type_label.underscore.gsub(" ", "_")
  end

  private def set_initial_sort_order
    next_sort_order = ( survey.questions.max(:sort_order) || 0 ) + 1
    self.sort_order = next_sort_order
  end

end