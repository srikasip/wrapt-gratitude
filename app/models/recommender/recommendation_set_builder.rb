module Recommender
  class RecommendationSetBuilder
    
    attr_reader :recommendations_set, :profile, :previous_recommendation_set

    def initialize(profile, params)
      @profile = profile
      @previous_recommendation_set = profile.current_recommendation_set
      @recommendation_set = profile.recommendation_sets.build(
        engine_type: params[:engine_type],
        engine_params: params
      )
    end
    
    def build
      copy_previous_recommendations
      generate_new_recommendations
      true
    end
    
    def save!
      recommendation_set.save!
    end
     
    def copy_previous_recommendations
      return false if previous_recommendation_set.blank?
      
      recommendations_set.generation_number = previous_recommendation_set.generation_number + 1
      
      previous_recommendations.each_with_index do |prev_rec, pos|
        rec = prev_rec.dup
        rec.viewed = true
        rec.postion = pos
        recommendations << rec
      end
      
      true
    end
    
    def generate_new_recommendations
      engine.run
      recommendation_set.engine_stats = engine.stats
      engine.recommendations.each do |rec|
        rec.position = recommendations_set.size
        recommendations_set << rec
      end
      true
    end
        
    def previous_recommendations
      previous_recommendation_set.recommendations
    end
    
    def recommendations
      recommendations_set.recommendations
    end
    
    def engine
      @_engine || create_engine
    end
    
    def create_engine
      type_to_class = {'survey_response_engine' => Recommender::SurveyResponseEngine}
      engine_class = type_to_class[recommendations_set.engine_type]
      @_engine = engine_class.new(recommendations_set)
    end

  end
end