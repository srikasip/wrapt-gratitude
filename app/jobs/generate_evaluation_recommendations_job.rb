class GenerateEvaluationRecommendationsJob < ApplicationJob
  queue_as :default

  def perform training_set_evaluation
    training_set_evaluation.recommendations.destroy_all

    training_set_evaluation.profile_sets.preload(:survey_responses).each do |profile_set|
      profile_set.survey_responses.each do |response|
        Recommendations::Engine.new(training_set_evaluation.training_set, response).generate_recommendations!
      end
    end

    training_set_evaluation.touch
  end
end
