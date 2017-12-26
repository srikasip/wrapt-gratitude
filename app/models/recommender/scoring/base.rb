module Recommender
  module Scoring
    class Base
      
      attr_reader :engine
      
      include Recommender::SurveyResponseParameters
      
      def initialize(engine)
        @engine = engine
        
        load_params
      end

      def name
        self.class.name.demodulize.underscore.humanize.titleize
      end
      
      def description
        ""
      end
      
      def load_params
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