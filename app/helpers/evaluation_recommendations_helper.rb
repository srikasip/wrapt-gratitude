module EvaluationRecommendationsHelper
  
  def displayable_response question_response
    case question_response.survey_question
    when SurveyQuestions::MultipleChoice then question_response.survey_question_option.text
    when SurveyQuestions::Range then question_response.range_response
    end    
  end

  def displayable_response_weight product_question, question_response
    case question_response.survey_question
    when SurveyQuestions::MultipleChoice
      impact = product_question.response_impacts.detect do |impact|
        impact.survey_question_option_id == question_response.survey_question_option_id
      end
      impact.impact
    when SurveyQuestions::Range then "1"
    end
  end

  def calculate_question_rank product_question, question_response
    calculator_class = case product_question.survey_question
    when SurveyQuestions::MultipleChoice then Recommendations::QuestionRankCalculators::MultipleChoice
    when SurveyQuestions::Range then Recommendations::QuestionRankCalculators::Range
    end
    
    calculator_class.new(product_question, question_response).question_rank
  end

end