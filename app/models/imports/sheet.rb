module Imports
  class Sheet
    attr_accessor :cached_columns

    def initialize(uploader, importable_class)
      @cached_columns = {}
      @roo_sheet = Roo::Spreadsheet.open(uploader.file)
      @importable_class = importable_class
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
      row_number_enumeration.each {|row_number| yield row(row_number)}
    end

    def map
      row_number_enumeration.map {|row_number| yield row(row_number)}
    end

    ##

    def row_number_enumeration
      2..@roo_sheet.count
    end

    def row(row_number)
      roo_row = @roo_sheet.row(row_number)
      row = row_class.new(one_to_one_row_hash(roo_row).merge({row_number: row_number}))
      row.many_to_one_values = roo_row[many_to_one_column_start..many_to_one_column_limit]
      row
    end

    ###

    def one_to_one_row_hash(roo_row)
      one_to_one_header_order.zip(roo_row).to_h
    end

    def many_to_one_column_limit
      100
    end

    def many_to_one_column_start
      one_to_one_header_order.count
    end

    ####

    def one_to_one_header_order
      @_one_to_one_header_order ||= header_row - row_class::MANY_TO_ONE_HEADERS
    end

    #####

    def header_row
      @_header_row ||= @roo_sheet.row(1).compact
    end

    def row_class
      "#{@importable_class}::Imports::Row".constantize
    end
  end
end
