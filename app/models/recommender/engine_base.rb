module Recommender
  class EngineBase
    
    attr_reader :recommendation_set, :recommendations, :stats
    
    delegate :profile, :engine_params, to: recommendation_set
    
    def initialize(recommendation_set)
      @recommendation_set = recommendation_set
      @recommendation_set.engine_params['max_total'] ||= 18
    end
    
    def max_total
      engine_params['max_total']
    end
    
    def run
      reset 
      @recommendations
    end

    def reset
      @recommendations = []
      @stats = {}
    end

    def save_recommendations!
      @recommendation_set.update_attributes(engine_stats: stats)
      @recommendations.map(&:save)
    end

    def destroy_recommendations!
      GiftRecommendation.where(profile: profile).destroy_all
    end
  end
end