module Recommendations
  class Engine

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
      Product.all.each do |product|
        product_rank = 0
        @response.survey.questions.each do |question|
          question_rank = calculate_question_rank(product, question)
          question_rank = Recommendations::NegativeRankPenaltyApplicator.new(question_rank).modified_rank
          question_rank = Recommendations::ProductQuestionWeightApplicator.new(question_rank, engine: self, product: product, question: question).modified_rank
          product_rank += question_rank
        end
        # TODO accomodate front-end responses
        EvaluationRecommendation.create survey_response: response, product: product, training_set_evaluation: training_set.evaluation, score: product_rank
      end
    end

    private def calculate_question_rank product, question
      calculator_class = case question
      when SurveyQuestions::MultipleChoice then calculate_multiple_choice_question_rank product, question
      when SurveyQuestions::Range then calculate_range_question_rank product, question
      end
      calculator_class.new(product, question, engine: self).get_question_rank
    end
    

    private def calculate_range_question_rank product, question
      result = 0
      question_response = question_responses_by_question[question]
      product_question = product_questions_by_product_and_question[product][question]
      if question_response && product_question
        modifier = product_question.range_impact_direct_correlation? ? 1 : -1
        result = question_response.range_response * modifier
      end
      result
    end

    private def calculate_multiple_choice_question_rank product, question
      # TODO accomodate multiple responses
      result = 0
      question_response = question_responses_by_question[question]
      product_question = product_questions_by_product_and_question[product][question]
      if question_response && product_question
        chosen_option_id = question_response.survey_question_option_id
        impact = product_question.response_impacts.detect{|impact| impact.survey_question_option_id == chosen_option_id}
        result = impact.impact
      end
      result
    end

    private def apply_product_question_weight question_rank, product, question
      weight = product_questions_by_product_and_question[product][question].question_impact
      question * (4 ** weight)
    end
    
    def product_questions_by_product_and_question
      @product_questions_by_product_and_question ||= {}.tap do |result|
        training_set.product_questions.preload(:product, :question, :response_impacts).each do |product_question|
          result[product] ||= {}
          result[product][question] = product_question
        end
      end
    end

    class SurveyMismatchError; end

  end
end