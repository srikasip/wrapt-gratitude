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
        engine.survey.questions.each do |question|
          if question.is_a?(SurveyQuestions::MultipleChoice)
            if question.price_filter?
              filters << Recommendations::Filters::Price.new(engine, question)
            end
          end
        end
        filters
      end

    end
  end
end