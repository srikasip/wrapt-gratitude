class SurveyQuestionOption < ApplicationRecord
  belongs_to :question, class_name: 'SurveyQuestion', inverse_of: :options, foreign_key: :survey_question_id
  mount_uploader :image, SurveyQuestionOptionImageUploader

  has_many :training_set_response_impacts, dependent: :destroy
  has_many :survey_question_responses, dependent: :destroy

  before_create :set_initial_sort_order

  private def set_initial_sort_order
    next_sort_order = ( question&.options&.maximum(:sort_order) || 0 ) + 1
    self.sort_order = next_sort_order
  end

end
