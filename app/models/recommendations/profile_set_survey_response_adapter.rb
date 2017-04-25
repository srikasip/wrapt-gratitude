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

    def create_recommendations!
      recommendations.each do |recommendation|
        recommendation.survey_response = response
        recommendation.training_set_evaluation = training_set.evaluation
        recommendation.save
      end
    end

    def destroy_recommendations!
      EvaluationRecommendation.where(
        survey_response: response,
        training_set_evaluation:
        training_set.evaluation).delete_all
    end
  end
end