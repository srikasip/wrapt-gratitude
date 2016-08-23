class SurveyQuestionOption < ApplicationRecord
  belongs_to :question, class_name: 'SurveyQuestion', inverse_of: :options
  mount_uploader :image, SurveyQuestionOptionImageUploader

  has_many :training_set_response_impacts, dependent: :destroy
  has_many :survey_question_responses, dependent: :destroy
end
