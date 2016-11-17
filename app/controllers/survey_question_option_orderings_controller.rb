class SurveyQuestionOptionOrderingsController < SortableListOrderingsController

  def sortables
    survey = Survey.find params[:survey_id]
    survey_question = survey.questions.find params[:question_id]
    return survey_question.options
  end

end