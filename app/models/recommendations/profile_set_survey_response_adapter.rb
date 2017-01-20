module Recommendations
  class ProfileSetSurveyResponseAdapter
    # Adapter to be used when the engine is generating recommendations from
    # a ProfileSetSurveyResponse (the admin training tools)

    attr_reader :engine

    delegate :response,
      :training_set,
      :recommendations,
      to: :engine

    def initialize(engine)
      @engine = engine
    end

    def add_recommendation(gift, score = 0.0)
      recommendation = EvaluationRecommendation.new(
        survey_response: response,
        gift: gift,
        training_set_evaluation: training_set.evaluation,
        score: score)
      
      recommendations << recommendation
      
      recommendation
    end

    def destroy_recommendations!
      EvaluationRecommendation.where(
        survey_response: response,
        training_set_evaluation:
        training_set.evaluation).delete_all
    end

  end
end