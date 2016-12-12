class TrainingSetEvaluationsController < ApplicationController

  def show
    set_training_set
    if @training_set.evaluation.blank?
      @training_set_evaluation = @training_set.create_evaluation!
      new_evaluation = true
    else
      @training_set_evaluation = @training_set.evaluation
    end
    if new_evaluation || (@training_set_evaluation.stale? && !@training_set_evaluation.recommendations_in_progress?)
      GenerateEvaluationRecommendationsJob.perform_later @training_set_evaluation
    end
    @recommendations_by_survey_response_id = @training_set_evaluation.recommendations.group_by(&:profile_set_survey_response_id)
  end

  private

    def set_training_set
      @training_set = TrainingSet.find params[:training_set_id]
    end
end