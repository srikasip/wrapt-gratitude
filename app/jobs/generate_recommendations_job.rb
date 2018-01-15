class GenerateRecommendationsJob < ApplicationJob
  queue_as :default

  def perform(profile, params)

    return if profile.recommendations_in_progress
    return if profile.recommendations_generated_at.present?

    profile.update_attribute :recommendations_in_progress, true
    
    profile.generate_gift_recommendation_set!(params)
  ensure
    profile.update_attribute :recommendations_in_progress, false
  end

end
