class GenerateRecommendationsJob < ApplicationJob
  queue_as :default

  def perform(survey_response)
    profile = survey_response.profile

    return if profile.recommendations_in_progress
    return if profile.recommendations_generated_at.present?

    profile.update_attribute :recommendations_in_progress, true
    recommendation_set = profile.recommendation_sets.build(
      engine_type: 'survey_response_engine',
      engine_params: {survey_response_id: survey_response.id}
    )
    recommendation_set.save!
    recommendation_set.generate_recommendations!
    profile.update_attribute(:recommendations_generated_at, Time.now)
  ensure
    profile.update_attribute :recommendations_in_progress, false
  end

end
