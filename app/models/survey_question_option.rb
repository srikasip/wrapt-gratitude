class SurveyQuestionOption < ApplicationRecord
  belongs_to :question, class_name: 'SurveyQuestion', inverse_of: :options, foreign_key: :survey_question_id
  mount_uploader :image, SurveyQuestionOptionImageUploader

  # unused relationships but they're here to clean up foreign keys
  has_many :training_set_response_impacts, dependent: :destroy
  has_many :survey_question_response_options, dependent: :destroy
  has_many :conditional_question_options, dependent: :destroy
  has_many :trait_response_options, dependent: :destroy

  before_create :set_initial_sort_order

  scope :standard, -> {where type: ['SurveyQuestionOption', nil]}

  private def set_initial_sort_order
    next_sort_order = ( question&.options&.maximum(:sort_order) || 0 ) + 1
    self.sort_order = next_sort_order
  end

end
