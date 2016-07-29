class SurveyQuestionsController < ApplicationController
  before_action :set_survey
  before_action :set_survey_question, only: [:edit, :update, :destroy]

  def new
    @survey_question = @survey.questions.new
  end

  def edit
  end

  def create
    @survey_question = @survey.questions.new(survey_params)
    
    if @survey_question.save
      redirect_to edit_survey_path(@survey), notice: 'Survey was successfully created.'
    else
      render :new
    end
  end

  def update    
    if @survey.update(survey_params)
      redirect_to edit_survey_path(@survey), notice: 'Survey was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @survey.destroy
    redirect_to surveys_url, notice: 'Survey was successfully destroyed.'
  end

  private
    def set_survey
      @survey = Survey.find(params[:survey_id])
    end

    def set_survey_question
      @survey_question = @survey_questions.find(params[:id])
    end

    def survey_params
      params.require(:survey_question).permit(:prompt)
    end
end
