class GiftRecommendation < ApplicationRecord
  belongs_to :survey_response
  belongs_to :gift
end
