class GenerateEvaluationRecommendationsJob < ApplicationJob
  queue_as :default

  def perform training_set_evaluation
    engine = Recommendations::Engine.new(training_set_evaluation.training_set)

    training_set_evaluation.profile_sets.preload(:survey_responses).each do |profile_set|
      profile_set.survey_responses.each do |response|
        engine.response = response
        engine.generate_recommendations
        EvaluationRecommendation.transaction do
          engine.destroy_recommendations!
          engine.create_recommendations!
        end
      end
    end

    training_set_evaluation.touch
    training_set_evaluation.update_attribute :recommendations_in_progress, false
  end
end