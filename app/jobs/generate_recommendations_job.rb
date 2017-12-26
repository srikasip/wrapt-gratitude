class GenerateRecommendationsJob < ApplicationJob
  queue_as :default

  def perform(recommendation_set)
    profile = recommendation_set.profile

    return if profile.recommendations_in_progress
    return if profile.recommendations_generated_at.present?

    profile.update_attribute :recommendations_in_progress, true
    recommendation_set.generate_recommendations!
    profile.update_attribute(:recommendations_generated_at, Time.now)
  ensure
    profile.update_attribute :recommendations_in_progress, false
  end

end
