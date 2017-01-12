module Admin
  module ProfileSetSurveyResponsesHelper
    
    def question_response_fields_partial question_response
      case question_response.survey_question
      when ::SurveyQuestions::MultipleChoice then 'multiple_choice_response_fields'
      when ::SurveyQuestions::Text then 'text_response_fields'
      when ::SurveyQuestions::Range then 'range_response_fields'
      end
    end

  end
end