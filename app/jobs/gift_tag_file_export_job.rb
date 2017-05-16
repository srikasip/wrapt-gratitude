require 'write_xlsx'

class GiftTagFileExportJob < ApplicationJob
  queue_as :default

  attr_reader :target_file_path, :workbook, :worksheet

  def perform(target_file_path)
    @target_file_path = target_file_path
    @workbook = WriteXLSX.new target_file_path
    @worksheet = workbook.add_worksheet

    write_headers!
    write_response_rows!
    set_column_widths!

    workbook.close
  end

  private def headers
    %w(
      sku
      name
      tag_list
    )
  end

  private def write_headers!
    headers.each_with_index do |header, i|
      worksheet.write 0, i, header
    end  
  end

  private def write_response_rows!
    row = 1
    # enable once we have tags
    Gift.all.preload(:tags).order(:wrapt_sku).each do |gift|
      worksheet.write row, 0, gift.wrapt_sku
      worksheet.write row, 1, gift.title
      worksheet.write row, 2, gift.tags.join(', ')
      row +=1
    end
  end
  

  private def set_column_widths!
    worksheet.set_column 0, 0, 20
    worksheet.set_column 1, 1, 80
    worksheet.set_column 2, 2, 80
  end
  
      
  
end
