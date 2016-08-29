class SurveyQuestionOptionOrderingsController < ApplicationController

  def create
    @survey = Survey.find params[:survey_id]
    @survey_question = @survey.questions.find params[:question_id]
    @survey_question_option_ordering = SurveyQuestionOptionOrdering.new(create_params.merge(survey_question: @survey_question))
    @survey_question_option_ordering.save
    head :ok
  end
   
  def create_params
    params.permit(ordering: [])
  end

end