module Recommender
  class RecommendationSetBuilder
    
    attr_reader :recommendation_set, :profile, :previous_recommendation_set, :append

    def initialize(profile, params = {})
      @profile = profile
      @previous_recommendation_set = profile.current_gift_recommendation_set
      @append = !!params[:append]
      @recommendation_set = profile.gift_recommendation_sets.build(
        engine_type: params[:engine_type].presence || 'survey_response_engine',
        engine_params: params
      )
    end
    
    def build
      copy_previous_recommendations
      generate_new_recommendations
      true
    end
    
    def append?
      append
    end
    
    def save!
      recommendation_set.save!
      profile.update_attribute(:recommendations_generated_at, Time.now)
      true
    end
     
    def copy_previous_recommendations
      return false if previous_recommendation_set.blank?
      return false if !append
      
      recommendation_set.generation_number = previous_recommendation_set.generation_number + 1
      
      previous_recommendations.each_with_index do |prev_rec, position|
        copied_rec = prev_rec.dup
        copied_rec.viewed = true
        copied_rec.position = position
        recommendations << copied_rec
      end
      
      true
    end
    
    def generate_new_recommendations
      engine.run
      recommendation_set.engine_stats = engine.stats
      engine.recommendations.each do |rec|
        rec.position = recommendations.size
        rec.generation_number = recommendation_set.generation_number
        recommendations << rec
      end
      true
    end
        
    def previous_recommendations
      previous_recommendation_set.recommendations
    end
    
    def recommendations
      recommendation_set.recommendations
    end
    
    def engine
      @_engine || create_engine
    end
    
    def create_engine
      type_to_class = {
        'survey_response_engine' => Recommender::SurveyResponseEngine
      }
      engine_class = type_to_class[recommendation_set.engine_type]
      @_engine = engine_class.new(recommendation_set)
    end

  end
end