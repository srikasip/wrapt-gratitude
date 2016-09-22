class SurveyQuestionsController < ApplicationController
  before_action :set_survey
  before_action :set_survey_question, only: [:show, :edit, :update, :destroy, :preview]

  def new
    @survey_question = @survey.questions.new
  end

  def edit
    if @survey_question.is_a? SurveyQuestions::MultipleChoice
      @survey_question_option = SurveyQuestionOption.new
      @options = @survey_question.options.standard
      render :edit_multiple_choice
    end
  end

  def create
    @survey_question = @survey.questions.new(create_params)
    
    if @survey_question.save
      redirect_to edit_survey_question_path(@survey, @survey_question), notice: 'The question was successfully created.'
    else
      render :new
    end
  end

  def update    
    if @survey_question.update(update_params)
      redirect_to edit_survey_question_path(@survey, @survey_question), notice: 'The question was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @survey_question.destroy
    redirect_to survey_url(@survey), notice: 'The question was successfully deleted.'
  end

  # ajax member action for multi-choice edit
  def preview
    render '_preview', layout: 'xhr'
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
        :mid_label,
        :include_other_option,
        :multiple_option_responses
      )
  end

end
