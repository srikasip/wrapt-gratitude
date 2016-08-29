class SurveyQuestionOrderingsController < ApplicationController

  def create
    @survey = Survey.find params[:survey_id]
    @survey_question_ordering = SurveyQuestionOrdering.new(create_params.merge(survey: @survey))
    @survey_question_ordering.save
    head :ok
  end
   
  def create_params
    params.permit(ordering: [])
  end

end