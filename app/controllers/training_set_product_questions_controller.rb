class TrainingSetProductQuestionsController < ApplicationController
  before_action :set_training_set
  before_action :set_training_set_product_question, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @training_set_product_question = @training_set.product_questions.new
  end

  def edit
  end

  def create
    @training_set_product_question = @training_set.product_questions.new(training_set_product_question_params)

    if @training_set_product_question.save
      redirect_to @training_set, notice: 'Product-Question was successfully created.'
    else
      render :new
    end
  end

  def update
    if @training_set_product_question.update(training_set_product_question_params)
      redirect_to @training_set, notice: 'Product-Question was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @training_set_product_question.destroy
    redirect_to @training_set, notice: 'Product-Question was successfully destroyed.'
  end

  private
    def set_training_set
      @training_set = TrainingSet.find params[:training_set_id]
    end

    def set_training_set_product_question
      @training_set_product_question = @training_set.product_questions.find(params[:id])
    end

    def training_set_product_question_params
      params.require(:training_set_product_question).permit(:product_id, :survey_question_id)
    end
end
