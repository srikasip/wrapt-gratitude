module Recommendations
  module QuestionRankCalculators
    class Range < Base

      def question_rank
        modifier = product_question.range_impact_direct_correlation? ? 1 : -1
        question_response.range_response * modifier
      end

    end
  end
end