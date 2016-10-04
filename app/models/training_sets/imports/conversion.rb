module TrainingSets
  module Imports
    class Conversion

      def initialize(row)
        @row = row
      end

      def question_impact
        @row.question_impact || 0
      end

      def range_impact_direct_correlation(question)
        if question.is_a?(SurveyQuestions::Range)
          !@row.slider_impact_direction.present? || @row.slider_impact_direction == 1
        end
      end

      def response_impacts(question)
        impacts = []
        if question.is_a? SurveyQuestions::MultipleChoice
          options = question.options.order(:sort_order).to_a
          i = 0

          @row.response_impacts.each do |impact|
            if options[i].present?
              impacts << options[i].training_set_response_impacts.new(impact: impact || 0)
            end
            i += 1
          end
        end

        impacts
      end
    end
  end
end
