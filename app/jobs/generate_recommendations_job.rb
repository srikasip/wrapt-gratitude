class GenerateRecommendationsJob < ApplicationJob
  queue_as :default

  def perform(survey_response)
    profile = survey_response.profile
    profile.update_attribute :recommendations_in_progress, true
    engine = Recommender::Engine.new(survey_response)
    engine.run
    GiftRecommendation.transaction do
      engine.destroy_recommendations!
      engine.create_recommendations!
    end
    profile.update_attributes(
      recommendation_stats: engine.stats,
      recommendations_generated_at: Time.now
    )
  ensure
    profile.update_attribute :recommendations_in_progress, false
  end

end
