class SurveyQuestionOption < ApplicationRecord
  belongs_to :question, class_name: 'SurveyQuestion', inverse_of: :options
  mount_uploader :image, SurveyQuestionOptionImageUploader
end
