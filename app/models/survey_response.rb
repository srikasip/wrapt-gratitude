class SurveyResponse < ApplicationRecord
  belongs_to :user
  has_many :gift_recommendations, dependent: :destroy
end
