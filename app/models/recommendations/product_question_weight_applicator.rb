require 'pp'
module Recommendations
  class ProductQuestionWeightApplicator
    
    attr_reader :question_rank, :question_weight

    def initialize question_rank, question_weight
      @question_rank = question_rank
      @question_weight = question_weight || 0
    end

    def modified_rank
      exponent = question_weight.abs
      sign = question_weight.abs < 0 ? -1.0 : 1.0
      question_rank * sign * (Recommendations::Engine::QUESTION_WEIGHT_BASE ** exponent)
    end

  end
end