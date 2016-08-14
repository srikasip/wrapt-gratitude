class ProfileSet < ApplicationRecord

  belongs_to :survey, inverse_of: :profile_sets

  has_many :survey_responses, class_name: 'ProfileSetSurveyResponse', inverse_of: :profile_set, dependent: :destroy

end
