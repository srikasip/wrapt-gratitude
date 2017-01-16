module Recommendations
  class Engine

    # TODO as of 8/31/16
    # accomodate the front end survey responses
    # accomodate multiple multiple choice questions
    # exclude text questions
    # tests

    attr_reader :training_set, :response

    NEGATIVE_RANK_PENALTY = 2
    QUESTION_WEIGHT_BASE = 10

    def initialize training_set
      @training_set = training_set
    end
    
    def response=(new_response)
      @response = new_response
      if training_set.survey_id != @response.survey_id
        raise SurveyMismatchError
      end
      @_question_responses_by_question = nil
      @response
    end

    def generate_recommendations!
      recommendations = []
      gifts.each do |gift|
        gift_rank = 0
        questions_by_gift[gift].each do |question|
          gift_rank += calculate_question_rank(gift, question)
        end
        if gift_rank > 0.0
          # TODO accomodate front-end responses
          recommendations << EvaluationRecommendation.new(survey_response: response, gift: gift, training_set_evaluation: training_set.evaluation, score: gift_rank)
        end        
      end
      recommendations.sort!{|a, b| b <=> a}
      recommendations = recommendations.take(10)
      
      recommendations.map(&:save)
      
      recommendations
    end

    def calculate_question_rank gift, question
      gift_question = gift_question_impacts_by_gift_and_question[gift][question]

      result = initial_question_rank(gift, question)
      result = Recommendations::NegativeRankPenaltyApplicator.new(result).modified_rank
      result = Recommendations::ProductQuestionWeightApplicator.new(result, gift_question&.question_impact).modified_rank
    end

    # TODO this is used by EvaluationRecommendations#show and could be moved closer to there
    def calculate_question_rank_intermediate_products gift, question
      gift_question = gift_question_impacts_by_gift_and_question[gift][question]
      result = {}
      result[:initial_question_rank] = initial_question_rank(gift, question)
      result[:negative_rank_penalty_applied] = Recommendations::NegativeRankPenaltyApplicator.new(result[:initial_question_rank]).modified_rank
      result[:question_weight_applied] = Recommendations::ProductQuestionWeightApplicator.new(result[:negative_rank_penalty_applied], gift_question&.question_impact).modified_rank
      result[:final_question_rank] = result[:question_weight_applied]
      result
    end

    private def initial_question_rank gift, question
      result = 0
      question_response = question_responses_by_question[question]
      gift_question = gift_question_impacts_by_gift_and_question[gift][question]
      if question_response && gift_question
        calculator_class = case question
        when ::SurveyQuestions::MultipleChoice then Recommendations::QuestionRankCalculators::MultipleChoice
        when ::SurveyQuestions::Range then Recommendations::QuestionRankCalculators::Range
        end
        result = calculator_class.new(gift_question, question_response).question_rank
      end
      result
    end

    private def gifts
      @_gifts ||= Gift.where id: training_set.gift_question_impacts.select(:gift_id)
    end

    private def questions_by_gift
      @_questions_by_gift ||= {}.tap do |result|
        training_set.gift_question_impacts.preload(:gift, :survey_question).each do |gift_question|
          result[gift_question.gift] ||= []
          result[gift_question.gift] << gift_question.survey_question
        end
      end
    end
    
    def gift_question_impacts_by_gift_and_question
      @_gift_question_impacts_by_gift_and_question ||= {}.tap do |result|
        training_set.gift_question_impacts.preload(:gift, :survey_question, :response_impacts).each do |gift_question|
          gift = gift_question.gift
          question = gift_question.survey_question
          result[gift] ||= {}
          result[gift][question] = gift_question
        end
      end
    end

    private def question_responses_by_question
      @_question_responses_by_question ||= {}.tap do |result|
        response.question_responses.preload(:survey_question).each do |question_response|
          result[question_response.survey_question] = question_response
        end
      end  
    end
    
    class SurveyMismatchError; end

  end
end