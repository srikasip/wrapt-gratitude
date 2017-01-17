module Admin
  class TrainingSetEvaluationsController < BaseController

    before_action :set_training_set

    def show
      if @training_set.evaluation.blank?
        @training_set_evaluation = @training_set.create_evaluation!
        new_evaluation = true
      else
        @training_set_evaluation = @training_set.evaluation
      end
      if new_evaluation || (@training_set_evaluation.stale? && !@training_set_evaluation.recommendations_in_progress?)
        @training_set_evaluation.update_attribute :recommendations_in_progress, true
        GenerateEvaluationRecommendationsJob.perform_later @training_set_evaluation
      end
      @recommendations_by_survey_response_id = @training_set_evaluation.recommendations.group_by(&:profile_set_survey_response_id)
    end

    def destroy
      @training_set.evaluation&.destroy
      redirect_to admin_training_set_evaluation_path(@training_set)
    end

    private

      def set_training_set
        @training_set = TrainingSet.find params[:training_set_id]
      end
  end
end
