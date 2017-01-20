module Recommendations
  class SurveyResponseAdapter
    # Adapter to be used when the engine is generating recommendations from
    # a SurveyResponse (the public survey)

    # Note, when we support multiple profiles this will need to be refactored to take into account
    # all of the survey responses for the profile

    attr_reader :engine

    delegate :response,
      :training_set,
      :recommendations
      to: :engine

    def initialize(engine)
      @engine = engine
    end

    def add_recommendation(gift, score = 0.0)
      recommendation = GiftRecommendation.new(
        profile: response.profile,
        gift: gift,
        score: score)
      
      recommendations << recommendation
      
      recommendation
    end

    # Note this destroys recommendations for the entire profile
    # That's fine because there's only 1 survey per profile right now
    # but be careful if that ever changes
    def destroy_recommendations!
      GiftRecommendation.where(profile: response.profile).delete_all
    end

  end
end