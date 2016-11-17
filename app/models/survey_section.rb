class SurveySection < ApplicationRecord
  belongs_to :survey, required: true, inverse_of: :sections
end
