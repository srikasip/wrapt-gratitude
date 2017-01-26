class GenerateProfileRecommendationsJob < ApplicationJob
  queue_as :default

  def perform(profile, training_set)
    profile.update_attribute :recommendations_in_progress, true
    engine = Recommendations::Engine.new(training_set)
    profile.survey_responses.each do |response|
      engine.response = response
      engine.generate_recommendations
      EvaluationRecommendation.transaction do
        engine.destroy_recommendations!
        engine.create_recommendations!
      end
    end
    profile.update_attribute :recommendations_generated_at, Time.now
  ensure
    profile.update_attribute :recommendations_in_progress, false
  end

end