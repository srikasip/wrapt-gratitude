require 'write_xlsx'

class InventoryExportJob < ApplicationJob
  include InventoryJobConstants

  queue_as :default

  attr_reader :target_file_path, :workbook, :worksheet, :params

  def perform(target_file_path, params)
    @target_file_path = target_file_path
    @workbook         = WriteXLSX.new target_file_path
    @worksheet        = workbook.add_worksheet
    @params           = params
    @params ||= {}
    @params[:search] ||= {}

    write_headers!
    write_response_rows!
    set_column_widths!

    workbook.close
  end

  private def headers
    COLUMN_DATA.map { |column_datum| column_datum.title }
  end

  private def write_headers!
    headers.each_with_index do |header, i|
      worksheet.write 0, i, header
    end
  end

  private def write_response_rows!
    row = 1
    products = InventorySearch.new(params).unpaginated_results
    products.each do |product|
      COLUMN_DATA.each_with_index do |field, column_number|
        worksheet.write row, column_number, product.send(field.getter.to_sym)
      end
      row +=1
    end
  end

  private def set_column_widths!
    worksheet.set_column 0, 0, 20
    worksheet.set_column 1, 1, 20
    worksheet.set_column 2, 2, 80
    worksheet.set_column 3, 3, 20
    worksheet.set_column 4, 4, 20
  end
end
