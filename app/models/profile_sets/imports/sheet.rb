module ProfileSets
  module Imports
    class Sheet
      attr_accessor :cached_columns

      def initialize(uploader)
        @cached_columns = {}
        @roo_sheet = Roo::Spreadsheet.open(uploader.file)
      end

      def cache_columns_scan!(*column_names)
        if !column_names.map {|name| @cached_columns[name]}.all?
          @cached_columns = column_names.map {|name| [name, []]}.to_h
          each do |row|
            column_names.each do |name|
              @cached_columns[name] << row.send(name)
            end
          end
        end
        self
      end

      #

      def each
        (2..@roo_sheet.count).each do |row_number|
          roo_row = @roo_sheet.row(row_number)
          row = Row.new(non_numeric_row_hash(roo_row))
          row.numeric_responses = roo_row[numeric_column_start..numeric_column_limit]
          yield row
        end
      end

      ##

      def non_numeric_row_hash(roo_row)
        non_numeric_header_order.zip(roo_row).to_h
      end

      def numeric_column_limit
        100
      end

      def numeric_column_start
        non_numeric_header_order.count
      end

      ###

      def non_numeric_header_order
        @_non_numeric_header_order ||= header_row - Row::NUMERIC_HEADERS
      end

      ####

      def header_row
        @_header_row ||= @roo_sheet.row(1).compact
      end
    end
  end
end
