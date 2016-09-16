module Recommendations
  class Engine

    # TODO as of 8/31/16
    # accomodate the front end survey responses
    # accomodate multiple multiple choice questions
    # exclude text questions
    # tests

    attr_reader :training_set, :response

    NEGATIVE_RANK_PENALTY = 2
    QUESTION_WEIGHT_BASE = 4

    def initialize training_set, response
      @training_set = training_set
      @response = response
      if training_set.survey_id != response.survey_id
        raise SurveyMismatchError
      end
    end

    def generate_recommendations!
      gifts.each do |gift|
        gift_rank = 0
        questions_by_gift[gift].each do |question|
          gift_rank += calculate_question_rank(gift, question)
        end
        # TODO accomodate front-end responses
        EvaluationRecommendation.create survey_response: response, gift: gift, training_set_evaluation: training_set.evaluation, score: gift_rank
      end
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
        when SurveyQuestions::MultipleChoice then Recommendations::QuestionRankCalculators::MultipleChoice
        when SurveyQuestions::Range then Recommendations::QuestionRankCalculators::Range
        end
        result = calculator_class.new(gift_question, question_response).question_rank
      end
      result
    end

    private def gifts
      Gift.where id: training_set.gift_question_impacts.select(:gift_id)
    end

    private def questions_by_gift
      training_set.gift_question_impacts.preload(:gift, :survey_question).to_a.reduce(Hash.new()) do |result, gift_question|
        result[gift_question.gift] ||= []
        result[gift_question.gift] << gift_question.survey_question
        result
      end
    end
    
    def gift_question_impacts_by_gift_and_question
      @gift_question_impacts_by_gift_and_question ||= {}.tap do |result|
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