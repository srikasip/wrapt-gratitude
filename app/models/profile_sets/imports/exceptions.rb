module ProfileSets
  module Imports
    module Exceptions
      class PreloadsNotFound < StandardError
        attr_accessor :sheet_column_name, :lookups

        def initialize(sheet_column_name, lookups)
          @sheet_column_name = sheet_column_name
          @lookups = lookups
        end
      end
    end
  end
end
