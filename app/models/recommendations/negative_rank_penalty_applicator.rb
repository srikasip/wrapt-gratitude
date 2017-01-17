module Recommendations
  class NegativeRankPenaltyApplicator
    
    attr_reader :question_rank

    def initialize question_rank
      @question_rank = question_rank
    end

    def modified_rank
      if question_rank < 0
        question_rank * Recommendations::Engine::NEGATIVE_RANK_PENALTY
      else
        question_rank
      end
    end

  end
end