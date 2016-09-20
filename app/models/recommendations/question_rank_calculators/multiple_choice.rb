module Recommendations
  module QuestionRankCalculators
    class MultipleChoice < Base

      def question_rank
        result = 0
        chosen_option_ids = question_response.survey_question_option_ids
        product_question.response_impacts.each do |impact|
          if impact.survey_question_option_id.in? chosen_option_ids
            result += impact.impact
          end
        end
        return result
      end

    end
  end
end