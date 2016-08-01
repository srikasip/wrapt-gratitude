class SurveyQuestionOptionsController < ApplicationController
  before_action :set_survey
  before_action :set_survey_question
  before_action :set_survey_question_option, only: [:edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
    @survey_question_option = @survey_question.options.new
  end


  def edit
  end

  def create
    @survey_question_option = @survey_question.options.new(survey_question_option_params)
    
    if @survey_question_option.save
      redirect_to survey_path(@survey), notice: 'Survey Question Option was successfully created.'
    else
      render :new
    end
  end

  def update    
    if @survey_question_option.update(survey_question_option_params)
      redirect_to survey_path(@survey), notice: 'Survey Question Option was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @survey_question_option.destroy
    redirect_to surveys_url, notice: 'Survey Question Option was successfully destroyed.'
  end

  private
    def set_survey
      @survey = Survey.find(params[:survey_id])
    end

    def set_survey_question
      @survey_question = @survey.questions.find(params[:question_id])
    end

    def set_survey_question_option
      @survey_question_option = @survey_question.options.find(params[:id])
    end

    def survey_question_option_params
      params.require(:survey_question_option).permit(:text, :image, :remove_image)
    end
end
