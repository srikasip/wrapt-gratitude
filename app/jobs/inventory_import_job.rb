class InventoryImportJob < ApplicationJob
  include InventoryJobConstants

  queue_as :default

  attr_reader :file, :worksheet, :errors

  def perform(file)
    @file = file
    @errors = []
    if open_file
      process_rows
    end
    @errors.empty?
  end

  def open_file
    if file.present?
      begin
        @worksheet = Roo::Spreadsheet.open(file)
      rescue ArgumentError, IOError
        log_error("Error reading import file")
        return false
      end
    else
      log_error("Import file required")
      return false
    end
    true
  end

  def process_rows
    CSV.parse(@worksheet.to_csv, CSV_CONFIG).each_with_index do |row,i|
      @row_number = i+2
      process_one_row(row)
    end
  end

  def process_one_row(row)
    if row['wrapt_sku'].blank?
      log_error("Missing Wrapt SKU")
      return
    end

    @product = Product.where(wrapt_sku: row['wrapt_sku']).first_or_initialize

    WRITABLE_COLUMNS.each do |column|
      if row[column].present?
        @product.send(column+'=', row[column])
      end
    end

    unless @product.save
      log_error(@product.errors.full_messages.join('. '))
    end
  end

  def log_error(message)
    if @row_number
      @errors << "#{@row_number}: #{message}"
    else
      @errors << message
    end
  end
end
