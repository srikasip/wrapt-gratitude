module TrainingSets
  module Imports
    class Sheet

      def initialize(uploader)
        @roo_sheet = Roo::Spreadsheet.open(uploader.file)
      end

      #

      def header_row
        @_header_row ||= @roo_sheet.row(1).compact
      end
    end
  end
end
