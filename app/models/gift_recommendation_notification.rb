class GiftRecommendationNotification < ApplicationRecord

  belongs_to :user
  belongs_to :gift_recommendation_set
  belongs_to :gift_recommendation

end