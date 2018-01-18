class GiftRecommendationSet < ApplicationRecord
  belongs_to :profile, touch: true
  has_many :recommendations, -> {order(position: :asc)},
    dependent: :destroy, class_name: 'GiftRecommendation', foreign_key: :recommendation_set_id
  
  belongs_to :expert, class_name: 'User'

  serialize :engine_params
  serialize :engine_stats
  
  ENGINE_TYPES = %w{survey_response_engine}
  
  TTL = 30.days
  
  validates :engine_type, inclusion: {in: ENGINE_TYPES}
  
  def self.active
    rs_t = GiftRecommendationSet.arel_table
    where(rs_t[:updated_at].gt(TTL.ago)).
    where(id: GiftRecommendation.available.select(:recommendation_set_id))
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
  
  def visible_recommendations
    if @_visible_recommendations.nil?
      @_visible_recommendations = []
      recommendations.each do |rec|
        if !rec.removed_by_expert? && rec.gift.available?
          if rec.added_by_expert? || @_visible_recommendations.size < 12
            @_visible_recommendations << rec
          end
        end
      end
    end
    @_visible_recommendations
  end
end