module Recommendations
  class SurveyResponseAdapter
    # Adapter to be used when the engine is generating recommendations from
    # a SurveyResponse (the public survey)

    # Note, when we support multiple profiles this will need to be refactored to take into account
    # all of the survey responses for the profile

    attr_reader :engine

    delegate :response,
      :training_set,
      :recommendations,
      to: :engine

    def initialize(engine)
      @engine = engine
    end

    def create_recommendations!
      @recommendations.each do |recommendation|
        recommendation.profile = response.profile
        recommendation.save
      end
    end

    # Note this destroys recommendations for the entire profile
    # That's fine because there's only 1 survey per profile right now
    # but be careful if that ever changes
    def destroy_recommendations!
      GiftRecommendation.where(profile: response.profile).delete_all
    end

  end
end