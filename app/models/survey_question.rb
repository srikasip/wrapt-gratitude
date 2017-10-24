class SurveyQuestion < ApplicationRecord
  # abstract base class for survey questions
  belongs_to :survey, inverse_of: :questions
  has_many :gift_question_impacts, dependent: :destroy

  # type-specific associations are on the base class for preloading
  has_many :options, -> {order :sort_order}, inverse_of: :question, dependent: :destroy, class_name: 'SurveyQuestionOption'

  has_many :survey_question_responses, dependent: :destroy

  belongs_to :conditional_question, class_name: 'SurveyQuestion', required: false
  has_many :conditional_question_options, inverse_of: :survey_question, dependent: :destroy
  #has_many :trait_training_set_questions, inverse_of: :question, dependent: :destroy, foreign_key: :question_id

  belongs_to :survey_section, inverse_of: :questions
  validate :survey_id_matches_survey_section_survey_id

  scope :not_text, -> {where.not(type: 'SurveyQuestions::Text')}

  # done this way so we don't replace if there's a validation error
  attr_accessor :conditional_question_option_option_ids
  after_save :replace_conditional_question_options, if: :conditional_question_option_option_ids

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
    next_sort_order = ( section_or_uncategorized&.questions.maximum(:sort_order) || 0 ) + 1
    self.sort_order = next_sort_order
  end

  def prompt_with_substitutions survey_response
    result = prompt
    result = substitute_name result, survey_response
    result = substitute_relationship result, survey_response
    return result
  end

  private def substitute_name string, survey_response
    result = string
    if name_question = survey.name_question
      if name_response = survey_response.question_responses.where(survey_question: name_question).first&.text_response.presence
        result = result.gsub /<name>/i, name_response
      end
    end
    return result
  end

  private def substitute_relationship string, survey_response
    result = string
    if relationship_question = survey.relationship_question
      if relationship_response = survey_response.question_responses.where(survey_question: relationship_question).first&.survey_question_options&.first&.text&.downcase.presence
        result = result.gsub /<relationship>/i, relationship_response
      end
    end
    return result
  end




  private def set_conditional_display
    @conditional_display = conditional_question_id?
  end

  def conditional_display= value
    @conditional_display = value
    if !value || value == "0"
      self.conditional_question = nil
      self.conditional_question_option_option_ids = []
    end
    return value
  end

  def first_in_section?
    survey_section.questions.first == self
  end

  def second_in_section?
    survey_section.questions.second == self
  end

  private def replace_conditional_question_options
    conditional_question_options.delete_all
    conditional_question_option_option_ids.each do |option_id|
      conditional_question_options.create survey_question_option_id: option_id
    end
  end

  def section_or_uncategorized
    survey_section || survey&.uncategorized_section
  end

  private def survey_id_matches_survey_section_survey_id
    if survey_section && survey_id != survey_section.survey_id
      errors.add :survey_section, 'Must be from this question\'s survey'
    end
  end
end
