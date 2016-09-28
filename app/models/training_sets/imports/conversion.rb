module TrainingSets
  module Imports
    class Conversion

      def initialize(row)
        @row = row
      end

      def question_impact
        @row.question_impact
      end

      def range_impact_direct_correlation(question)
        !question.is_a?(SurveyQuestions::Range) || @row.response_impacts.first.to_i == 1
      end

      def response_impacts(question)
        impacts = []
        if question.is_a? SurveyQuestions::MultipleChoice
          options = question.options.order(:sort_order).to_a
          i = 0

          @row.response_impacts.each do |impact|
            if options[i].present?
              impacts << options[i].training_set_response_impacts.new(impact: impact)
            end
            i += 1
          end
        end

        impacts
      end
    end
  end
end
