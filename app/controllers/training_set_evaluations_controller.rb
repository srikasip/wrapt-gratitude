class TrainingSetEvaluationsController < ApplicationController
  before_action :set_training_set_evaluation, only: [:show, :destroy]

  def index
    @training_set_evaluations = TrainingSetEvaluation.all.page(params[:page]).per(50)
    @training_set_evaluation = TrainingSetEvaluation.new
  end

  def create
    @training_set_evaluation = TrainingSetEvaluation.new(training_set_evaluation_params)

    if @training_set_evaluation.save
      GenerateEvaluationRecommendationsJob.perform_later @training_set_evaluation
      redirect_to training_set_evaluation_path(@training_set_evaluation), notice: 'Evaluation was successfully created.'
    else
      render :index
    end
  end

  def show
    @recommendations_by_survey_response_id = @training_set_evaluation.recommendations.group_by(&:profile_set_survey_response_id)
  end

  def destroy
    @training_set_product_question.destroy
    redirect_to @training_set, notice: 'Product-Question was successfully deleted.'
  end

  private

    def set_training_set_evaluation
      @training_set_evaluation = TrainingSetEvaluation.find params[:id]
    end

    def training_set_evaluation_params
      params.require(:training_set_evaluation).permit(:training_set_id)
    end
end
