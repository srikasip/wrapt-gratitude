module ProfileSets
  module Imports
    class Conversion

      def initialize(row)
        @row = row
      end

      def range_response(question)
        if question.is_a? SurveyQuestions::Range
          @row.numeric_responses.first
        end
      end

      def survey_question_response_options(question)
        responses = []

        if question.is_a? SurveyQuestions::MultipleChoice
          options = question.options.order(:sort_order).to_a
          i = 0

          @row.numeric_responses.each do |response|
            if response.to_i == 1
              responses << options[i].survey_question_response_options.new
            end

            i += 1
          end
        end

        responses
      end

      def text_response
        @row.text_response
      end
    end
  end
end
