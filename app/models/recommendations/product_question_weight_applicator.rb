module Recommendations
  class ProductQuestionWeightApplicator
    
    attr_reader :question_rank, :engine, :product, :question

    def initialize question_rank, **attrs
      @question_rank = question_rank
      @engine = attrs.fetch :engine
      @product = attrs.fetch :product
      @question = attrs.fetch :question
    end

    def modified_rank
      weight = engine.product_questions_by_product_and_question[product][question].question_impact
      question_rank * (4 ** weight)
    end

  end
end