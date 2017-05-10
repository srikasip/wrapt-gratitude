module Recommender
  class Engine
    
    attr_reader :survey_response, :recommendations,
      :min_total, :max_total, :min_random, :max_random
    
    delegate :profile, :survey, :question_responses, to: :survey_response
    
    def initialize(survey_response)
      @survey_response = survey_response
      @min_total = 12
      @max_total = 12
      @min_random = 2
      @max_random = 2
      
      reset
    end
    
    def run
      reset
    end
    
    def reset
      @recommendations = []
    end
    
    def create_recommendations!
    end
    
    def destroy_recommendations!
    end
    
  end
end