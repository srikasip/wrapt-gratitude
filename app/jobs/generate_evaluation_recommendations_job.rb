class GenerateEvaluationRecommendationsJob < ApplicationJob
  queue_as :default

  def perform training_set_evaluation
    training_set_evaluation.recommendations.destroy_all

    all_product_ids = Product.all.pluck :id

    training_set_evaluation.profile_sets.preload(:survey_responses).each do |profile_set|
      profile_set.survey_responses.each do |response|
        # generate random recommendations for now
        2.times do
          EvaluationRecommendation.create training_set_evaluation: training_set_evaluation,
            survey_response: response,
            product_id: all_product_ids.sample,
            score: Random.rand(1.0)
        end

      end
    end
  end
end
