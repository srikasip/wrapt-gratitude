class GiftRecommendationSet < ApplicationRecord
  belongs_to :profile
  has_many :recommendations, -> {order(position: :asc)},
    dependent: :destroy, class_name: 'GiftRecommendation', foreign_key: :recommendation_set_id
  
  belongs_to :expert, class_name: 'User'

  serialize :engine_params
  serialize :engine_stats

  has_many :gift_recommendation_notifications, dependent: :destroy
  
  ENGINE_TYPES = %w{survey_response_engine}
  
  validates :engine_type, inclusion: {in: ENGINE_TYPES}  
end