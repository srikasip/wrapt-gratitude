module Recommender
  module Scoring
    class Base
      
      attr_reader :engine
      
      def initialize(engine)
        @engine = engine
        
        load_params
      end
      
      def load_params
      end
      
      def find_params(name)
        params = []
        engine.question_responses.each do |response|
          response.survey_question_options.each do |option|
            option_param = option.configuration_params[name.to_s]
            params << option_param if option_param.present?
          end
        end
        params
      end
      
      def valid?
        false
      end
      
      def invalid?
        !valid?
      end

      def scoring_sql
        nil
      end
      
      def self.create_scorers(engine)
        [
          Recommender::Scoring::Standard,
          Recommender::Scoring::TagBoost
        ].map do |klass|
          klass.new(engine)
        end.select(&:valid?)
      end
      
    end
  end
end