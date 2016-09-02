module Recommendations
  class DataStore
    
    attr_reader :training_set, :response

    def initialize(training_set, response)
      @training_set, @response = training_set, response
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

    def question_responses_by_question
      @_question_responses_by_question ||= {}.tap do |result|
        response.question_responses.each do |question_response|
          result[question_response.survey_question] = question_response
        end
      end  
    end

    def products
      Product.where id: training_set.product_questions.select(:product_id)
    end

    def questions_by_product
      training_set.product_questions.preload(:product, :survey_question).to_a.reduce(Hash.new()) do |result, product_question|
        result[product_question.product] ||= []
        result[product_question.product] << product_question.survey_question
        result
      end
    end

  end
end