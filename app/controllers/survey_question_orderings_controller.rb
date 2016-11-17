class SurveyQuestionOrderingsController < SortableListOrderingsController

  def sortables
    survey = Survey.find params[:survey_id]
    return survey.questions
  end

end