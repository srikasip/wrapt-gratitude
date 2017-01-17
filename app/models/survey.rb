class Survey < ApplicationRecord

  has_many :questions, -> {order 'sort_order asc'}, class_name: 'SurveyQuestion', dependent: :destroy, inverse_of: :survey

  has_many :multiple_choice_questions, class_name: 'SurveyQuestions::MultipleChoice'
  has_many :text_questions, class_name: 'SurveyQuestions::Text'
  has_many :range_questions, class_name: 'SurveyQuestions::Range'

  has_one :name_question, -> {where use_response_as_name: true}, class_name: 'SurveyQuestion'

  has_many :profile_sets, inverse_of: :survey, dependent: :destroy
  has_many :training_sets, inverse_of: :survey, dependent: :destroy
  has_many :survey_responses, inverse_of: :survey, dependent: :destroy

  has_many :sections, -> {order 'sort_order ASC'}, class_name: 'SurveySection', inverse_of: :survey, dependent: :destroy

  scope :published, -> { where(published: true) }

  def sections_with_uncategorized
    sections.to_a.push uncategorized_section
  end

  def uncategorized_section
    @_uncategorized_section ||= NullSurveySection.new(survey: self)
  end

  def publish!
    Survey.update_all published: false
    self.published = true
    save validate: false
  end

end
