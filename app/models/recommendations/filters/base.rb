module Recommendations
  module Filters
    class Base
      
      include ActionView::Helpers::NumberHelper
      
      attr_reader :engine, :question
      
      delegate :response, to: :engine
      
      def initialize(engine, question)
        @engine = engine
        @question = question
      end
      
      def applied?
        false
      end
      
      def name
        "Filter"
      end
      
      def question_response
        engine.question_responses_by_question[question]
      end
      
      def apply(recommendations)
        recommendations
      end
      
      def self.create_filters(engine)
        filters = []
        engine.survey.questions.sort_by(&:sort_order).each do |question|
          if question.is_a?(SurveyQuestions::MultipleChoice)
            if question.price_filter?
              filters << Recommendations::Filters::Price.new(engine, question)
            elsif question.category_filter?
              filters << Recommendations::Filters::Category.new(engine, question)
            end
          end
        end
        filters
      end

    end
  end
end