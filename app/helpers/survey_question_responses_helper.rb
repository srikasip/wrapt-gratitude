module SurveyQuestionResponsesHelper
  
  def response_fields_partial
    case @question_response.survey_question
    when SurveyQuestions::MultipleChoice then multiple_choice_fields_partial
    when SurveyQuestions::Text then 'text_fields'
    when SurveyQuestions::Range then 'range_fields'
    #TODO yes/no
    end
  end

  def multiple_choice_fields_partial
    if @question_response.survey_question.multiple_option_responses
      'multiple_choice_choose_many_fields'
    else
      'multiple_choice_choose_one_fields'
    end
  end

  def question_response_next_button_text
    if @question_response.next_response
      'Next'
    else
      'Complete Quiz'
    end
  end



end