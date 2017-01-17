module Admin
  module SurveysHelper
    
    def question_partial question
      case question
      when ::SurveyQuestions::MultipleChoice then "multiple_choice_question"
      when ::SurveyQuestions::Text then "text_question"
      when ::SurveyQuestions::Range then "range_question"
      end
    end

  end
end