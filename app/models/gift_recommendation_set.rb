class GiftRecommendationSet < ApplicationRecord
  belongs_to :profile, touch: true
  has_many :recommendations, -> {order(position: :asc)},
    dependent: :destroy, class_name: 'GiftRecommendation', foreign_key: :recommendation_set_id
  
  belongs_to :expert, class_name: 'User'

  serialize :engine_params
  serialize :engine_stats

  has_many :gift_recommendation_notifications, dependent: :destroy
  
  ENGINE_TYPES = %w{survey_response_engine}
  TTL = 30.days
  MAX_TOTAL_NEW = 6
  
  validates :engine_type, inclusion: {in: ENGINE_TYPES}

  def engine
    @_engine || create_engine
  end
  
  def self.active
    rs_t = GiftRecommendationSet.arel_table
    where(rs_t[:updated_at].gt(TTL.ago)).
    where(id: GiftRecommendation.available.select(:recommendation_set_id))
  end
  
  def active?
    updated_at > TTL.ago && recommendations.select(&:avaialble?).any?
  end

  def engine_params
    self[:engine_params] ||= {}
  end
  
  def normalize_recommendation_positions!
    recommendations.reorder(position: :asc, score: :desc, id: :asc).each_with_index do |rec, position|
      rec.update_attribute(:position, position)
    end
  end
  
  def available_recommendations
    recommendations.select(&:available?)
  end
end