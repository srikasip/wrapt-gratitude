class SurveySection < ApplicationRecord
  belongs_to :survey, required: true, inverse_of: :sections
  has_many :questions, class_name: 'SurveyQuestion', inverse_of: :survey_section, dependent: :nullify

  before_create :set_initial_sort_order

  private def set_initial_sort_order
    next_sort_order = ( survey&.sections.maximum(:sort_order) || 0 ) + 1
    self.sort_order = next_sort_order
  end
end
