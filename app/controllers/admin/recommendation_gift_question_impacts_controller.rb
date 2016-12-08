module Admin
  class RecommendationGiftQuestionImpactsController < BaseController
    # Ajax controller for driving quick adjustments to the product questions from
    # a recommendation details view.
    # For the standard CRUD controller for a ProductQuestion, see ProductQuestionImpactsController
    before_action :set_training_set
    before_action :set_recommendation
    before_action :set_gift_question_impact

    include PjaxModalController
    helper GiftQuestionImpactsHelper

    def edit
    end

    def update
      if @gift_question_impact.update(gift_question_impact_params)
        flash[:notice] = 'Gift-Question was successfully updated.'
        redirect_to admin_training_set_evaluation_path(@training_set)
      else
        render :edit
      end
    end

    private
      def set_training_set
        @training_set = TrainingSet.find params[:training_set_id]
      end

      def set_recommendation
        @recommendation = @training_set.evaluation.recommendations.find params[:recommendation_id]
      end

      def set_gift_question_impact
        @gift_question_impact = @training_set.gift_question_impacts.find(params[:id])
      end

      def gift_question_impact_params
        params.require(:gift_question_impact).permit(
          :product_id,
          :survey_question_id,
          :question_impact,
          :range_impact_direct_correlation,
          response_impacts_attributes: [:id, :impact]
        )
      end
  end
end