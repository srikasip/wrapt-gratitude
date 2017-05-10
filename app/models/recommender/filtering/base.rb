module Recommender
  module Filtering
    class Base
      
      attr_reader :engine
      
      def initialize(engine)
        @engine = engine
      end
      
      def active?
        false
      end
      
      def inactive?
        !active?
      end

      def gift_scope
        nil
      end
      
      def self.create_filters(engine)
        [
          Recommender::Filtering::Price
        ].map do |klass|
          klass.new(engine)
        end.select(&:active?)
      end
      
    end
  end
end