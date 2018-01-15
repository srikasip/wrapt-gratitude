class GiftRecommendationSet < ApplicationRecord
  belongs_to :profile
  has_many :recommendations, -> {order(position: :asc)},
    dependent: :destroy, class_name: 'GiftRecommendation', foreign_key: :recommendation_set_id
  
  belongs_to :expert, class_name: 'User'

  serialize :engine_params
  serialize :engine_stats

  has_many :gift_recommendation_notifications, dependent: :destroy
  
  STALE_DATE = DateTime.now.utc.beginning_of_day - 30.days
  ENGINE_TYPES = %w{survey_response_engine}
  TTL = 30.days
  
  validates :engine_type, inclusion: {in: ENGINE_TYPES}

  def is_fresh?
    updated_at >= STALE_DATE
  end

  def engine
    @_engine || create_engine
  end
  
  def self.active
    t = GiftRecommendationSet.arel_table
    where(t[:updated_at].gt(TTL.ago))
  end
  
  def active?
    updated_at > TTL.ago
  end

  def engine_params
    self[:engine_params] ||= {}
  end
  
  def normalize_recommendation_positions!
    recommendations.reorder(position: :asc, score: :desc, id: :asc).each_with_index do |rec, position|
      rec.update_attribute(:position, position)
    end
  end
end