module ProductQuestionImpactsHelper

  def edit_body_partial training_set_product_question
    case training_set_product_question.survey_question
    when SurveyQuestions::MultipleChoice then "edit_body_multiple_choice"
    when SurveyQuestions::Range then "edit_body_range"
    end
  end

end