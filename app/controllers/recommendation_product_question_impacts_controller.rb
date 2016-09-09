class RecommendationProductQuestionImpactsController < ApplicationController
  # Ajax controller for driving quick adjustments to the product questions from
  # a recommendation details view.
  # For the standard CRUD controller for a ProductQuestion, see ProductQuestionImpactsController
  before_action :set_training_set
  before_action :set_recommendation
  before_action :set_training_set_product_question

  include PjaxModalController
  helper ProductQuestionImpactsHelper

  def edit
  end

  def update
    if @training_set_product_question.update(training_set_product_question_params)
      flash[:notice] = 'Product-Question was successfully updated.'
      redirect_to training_set_evaluation_path(@training_set)
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

    def set_training_set_product_question
      @training_set_product_question = @training_set.product_questions.find(params[:id])
    end

    def training_set_product_question_params
      params.require(:training_set_product_question).permit(
        :product_id,
        :survey_question_id,
        :question_impact,
        :switch_range_impact_direct_correlation,
        response_impacts_attributes: [:id, :impact]
      )
    end
end
