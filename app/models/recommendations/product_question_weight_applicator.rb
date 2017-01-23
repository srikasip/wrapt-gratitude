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
      # ignore the sign of the question weight it should not change
      # the direction of ranking. That direction is set by the response weights.
      question_rank * (Recommendations::Engine::QUESTION_WEIGHT_BASE ** exponent)
    end

  end
end