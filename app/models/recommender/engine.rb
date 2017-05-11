module Recommender
  class Engine
    
    attr_reader :survey_response, :recommendations, :filters,
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
      preload_models
      load_filters
      @recommendations
    end
    
    def reset
      @recommendations = []
      @filters = []
    end
    
    def create_recommendations!
    end
    
    def destroy_recommendations!
    end
    
    def load_filters
      @filters = Recommender::Filtering::Base.create_filters(self)
    end
    
    def preload_models
      preloader = ActiveRecord::Associations::Preloader.new
      preloader.preload([@survey_response],
        [
          :profile,
          :survey,
          question_responses: [:survey_question_options]
        ]
      )
    end
    
  end
end