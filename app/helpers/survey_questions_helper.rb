module SurveyQuestionsHelper
  
  def form_fields_partial question
    case question
    when SurveyQuestions::Range then 'range_fields'
    when SurveyQuestions::MultipleChoice then 'multiple_choice_fields'
    when SurveyQuestions::Text then 'text_fields'
    end
  end

  def preview_partial question
    case question
    when SurveyQuestions::Range then 'range_preview'
    when SurveyQuestions::MultipleChoice then 'multiple_choice_preview'
    when SurveyQuestions::Text then 'text_preview'
    end
  end

end