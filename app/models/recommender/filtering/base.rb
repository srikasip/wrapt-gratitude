module Recommender
  module Filtering
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
      
      def exclusive_scope?
        false
      end

      def gift_scope
        nil
      end
      
      def self.create_filters(engine)
        [
          Recommender::Filtering::PriceRange,
          Recommender::Filtering::ExcludeTags
        ].map do |klass|
          klass.new(engine)
        end.select(&:valid?)
      end
      
    end
  end
end