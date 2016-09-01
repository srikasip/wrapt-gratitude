module Recommendations
  module QuestionRankCalculators
    class MultipleChoice < Base

      def question_rank
        chosen_option_id = question_response.survey_question_option_id
        impact = product_question.response_impacts.detect{|impact| impact.survey_question_option_id == chosen_option_id}
        impact&.impact || 0
      end

    end
  end
end