class TrainingSetEvaluationsController < ApplicationController

  def show
    set_training_set
    set_training_set_evaluation
    if @training_set_evaluation.stale?
      GenerateEvaluationRecommendationsJob.perform_later @training_set_evaluation
    end
    @recommendations_by_survey_response_id = @training_set_evaluation.recommendations.group_by(&:profile_set_survey_response_id)
  end

  private

    def set_training_set
      @training_set = TrainingSet.find params[:training_set_id]
    end

    def set_training_set_evaluation
      @training_set_evaluation = ( @training_set.evaluation || @training_set.create_evaluation! )
    end
end
