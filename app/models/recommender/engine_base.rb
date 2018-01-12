module Recommender
  class EngineBase
    
    attr_reader :recommendation_set, :recommendations, :stats
    
    delegate :profile, :engine_params, to: :recommendation_set
    
    def initialize(recommendation_set)
      @recommendation_set = recommendation_set
    end
    
    def run
      reset 
      @recommendations
    end

    def reset
      @recommendations = []
      @stats = {}
    end

  end
end
