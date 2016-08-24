class SurveyQuestionsController < ApplicationController
  before_action :set_survey
  before_action :set_survey_question, only: [:show, :edit, :update, :destroy]

  def new
    @survey_question = @survey.questions.new
  end

  def edit
  end

  def create
    @survey_question = @survey.multiple_choice_questions.new(create_params)
    
    if @survey_question.save
      redirect_to edit_survey_question_path(@survey, @survey_question), notice: 'Quiz Question was successfully created.'
    else
      render :new
    end
  end

  def update    
    if @survey_question.update(update_params)
      redirect_to edit_survey_question_path(@survey, @survey_question), notice: 'Quiz Question was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @survey_question.destroy
    redirect_to surveys_url, notice: 'Quiz was successfully deleted.'
  end

  private
  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def set_survey_question
    @survey_question = @survey.questions.find(params[:id])
  end

  def create_params
    params.require(:survey_question).permit(:prompt, :type)
  end

  def update_params
    params.require(@survey_question.model_name.param_key).permit(
        :prompt,
        :min_label,
        :max_label,
        :mid_label
      )
  end

end
