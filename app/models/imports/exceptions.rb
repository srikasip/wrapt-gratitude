module Imports
  module Exceptions
    class PreloadsNotFound < StandardError

      def initialize(preload_class, lookups)
        @preload_class = preload_class
        @lookups = lookups
      end

      def resource_name
        @preload_class.to_s.titleize
      end

      def values
        @lookups
      end
    end
  end
end
