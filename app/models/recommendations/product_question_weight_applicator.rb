require 'pp'
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
    rescue Exception => e
      puts "Error in modified rank"
      puts product.inspect
      puts question.inspect
      puts "pqbpaq"
      puts engine.product_questions_by_product_and_question[product].keys.map(&:id)
      puts '*******************'
      puts "qbp"
      puts engine.send(:questions_by_product)[product].map(&:id)
      raise e
    end

  end
end