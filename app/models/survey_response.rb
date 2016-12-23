class SurveyResponse < ApplicationRecord
  # TODO note this is just a stub: more functionality will be added in release 8

  belongs_to :user
  has_many :gift_recommendations, dependent: :destroy
end
