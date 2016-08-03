class TrainingSetProductQuestionsController < ApplicationController
  before_action :set_training_set_product_question, only: [:show, :edit, :update, :destroy]

  # GET /training_set_product_questions
  # GET /training_set_product_questions.json
  def index
    @training_set_product_questions = TrainingSetProductQuestion.all
  end

  # GET /training_set_product_questions/1
  # GET /training_set_product_questions/1.json
  def show
  end

  # GET /training_set_product_questions/new
  def new
    @training_set_product_question = TrainingSetProductQuestion.new
  end

  # GET /training_set_product_questions/1/edit
  def edit
  end

  # POST /training_set_product_questions
  # POST /training_set_product_questions.json
  def create
    @training_set_product_question = TrainingSetProductQuestion.new(training_set_product_question_params)

    respond_to do |format|
      if @training_set_product_question.save
        format.html { redirect_to @training_set_product_question, notice: 'Training set product question was successfully created.' }
        format.json { render :show, status: :created, location: @training_set_product_question }
      else
        format.html { render :new }
        format.json { render json: @training_set_product_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /training_set_product_questions/1
  # PATCH/PUT /training_set_product_questions/1.json
  def update
    respond_to do |format|
      if @training_set_product_question.update(training_set_product_question_params)
        format.html { redirect_to @training_set_product_question, notice: 'Training set product question was successfully updated.' }
        format.json { render :show, status: :ok, location: @training_set_product_question }
      else
        format.html { render :edit }
        format.json { render json: @training_set_product_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /training_set_product_questions/1
  # DELETE /training_set_product_questions/1.json
  def destroy
    @training_set_product_question.destroy
    respond_to do |format|
      format.html { redirect_to training_set_product_questions_url, notice: 'Training set product question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_training_set_product_question
      @training_set_product_question = TrainingSetProductQuestion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def training_set_product_question_params
      params.require(:training_set_product_question).permit(:training_set_id, :product_id, :question_id)
    end
end
