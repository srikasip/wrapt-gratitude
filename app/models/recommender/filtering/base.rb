module Recommender
  module Filtering
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