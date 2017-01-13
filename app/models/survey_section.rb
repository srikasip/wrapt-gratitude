class SurveySection < ApplicationRecord
  belongs_to :survey, required: true, inverse_of: :sections
  has_many :questions, -> {order :sort_order}, class_name: 'SurveyQuestion', inverse_of: :survey_section, dependent: :nullify

  before_create :set_initial_sort_order

  private def set_initial_sort_order
    next_sort_order = ( survey&.sections.maximum(:sort_order) || 0 ) + 1
    self.sort_order = next_sort_order
  end

  def introduction_heading_with_profile_relationship profile
    introduction_heading&.gsub /<relationship>/i, profile.relationship
  end

  def introduction_text_with_profile_relationship profile
    introduction_text&.gsub /<relationship>/i, profile.relationship
  end


end
