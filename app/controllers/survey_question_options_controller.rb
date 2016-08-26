# Ajax controller to control the survey builder

class SurveyQuestionOptionsController < ApplicationController
  before_action :set_survey
  before_action :set_survey_question
  layout 'xhr'


  def create
    @survey_question_option = @survey_question.options.new(survey_question_option_params)
    
    if @survey_question.save
      render 'survey_questions/_option_row', locals: {option: @survey_question_option}
    else
      head :bad_request
    end
  end

  def destroy
    @survey_question_option = @survey_question.options.find params[:id]
    @survey_question_option.destroy
    head :ok
  end

  def update    
    if @survey_question.update(update_params)
      redirect_to edit_survey_question_path(@survey, @survey_question), notice: 'Quiz Question was successfully updated.'
    else
      render :edit
    end
  end

  private
  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def set_survey_question
    @survey_question = @survey.questions.find(params[:question_id])
  end

  def survey_question_option_params
    params.require(:survey_question_option).permit(:text)
  end

end
