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
      if training_set.survey != response.survey
        raise SurveyMismatchError
      end
    end

    def generate_recommendations!
      products.each do |product|
        product_rank = 0
        questions_by_product[product].each do |question|
          product_question = product_questions_by_product_and_question[product][question]
          
          question_rank = calculate_question_rank(product, question)
          question_rank = Recommendations::NegativeRankPenaltyApplicator.new(question_rank).modified_rank
          question_rank = Recommendations::ProductQuestionWeightApplicator.new(question_rank, product_question&.question_impact).modified_rank
          
          product_rank += question_rank
        end
        # TODO accomodate front-end responses
        EvaluationRecommendation.create survey_response: response, product: product, training_set_evaluation: training_set.evaluation, score: product_rank
      end
    end

    private def calculate_question_rank product, question
      result = 0
      question_response = question_responses_by_question[question]
      product_question = product_questions_by_product_and_question[product][question]
      if question_response && product_question
        calculator_class = case question
        when SurveyQuestions::MultipleChoice then Recommendations::QuestionRankCalculators::MultipleChoice
        when SurveyQuestions::Range then Recommendations::QuestionRankCalculators::Range
        end
        result = calculator_class.new(product_question, question_response).question_rank
      end
      result
    end

    private def products
      Product.where id: training_set.product_questions.select(:product_id)
    end

    private def questions_by_product
      training_set.product_questions.preload(:product, :survey_question).to_a.reduce(Hash.new()) do |result, product_question|
        result[product_question.product] ||= []
        result[product_question.product] << product_question.survey_question
        result
      end
    end
    
    def product_questions_by_product_and_question
      @product_questions_by_product_and_question ||= {}.tap do |result|
        training_set.product_questions.preload(:product, :survey_question, :response_impacts).each do |product_question|
          product = product_question.product
          question = product_question.survey_question
          result[product] ||= {}
          result[product][question] = product_question
        end
      end
    end

    private def question_responses_by_question
      @_question_responses_by_question ||= {}.tap do |result|
        response.question_responses.each do |question_response|
          result[question_response.survey_question] = question_response
        end
      end  
    end
    
    class SurveyMismatchError; end

  end
end