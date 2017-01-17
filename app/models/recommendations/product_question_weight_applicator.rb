require 'pp'
module Recommendations
  class ProductQuestionWeightApplicator
    
    attr_reader :question_rank, :question_weight

    def initialize question_rank, question_weight
      @question_rank = question_rank
      @question_weight = question_weight || 0
    end

    def modified_rank
      question_rank * (Recommendations::Engine::QUESTION_WEIGHT_BASE ** question_weight)
    end

  end
end