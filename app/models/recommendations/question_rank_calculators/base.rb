module Recommendations
  module QuestionRankCalculators
    class Base
      
      attr_reader :product_question, :question_response

      def initialize product_question, question_response
        @product_question, @question_response = product_question, question_response
      end

      def question_rank
        raise "Abstract Method"
      end


    end
  end
end