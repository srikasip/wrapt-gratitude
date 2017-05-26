require 'write_xlsx'

class GiftTagFileImportJob < ApplicationJob
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
       rescue Exception
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
    # skip header row
    @row_number = 2
    while (@row_number <= @worksheet.last_row) do
      process_current_row
      @row_number += 1
    end
  end
  
  def process_current_row
   gift_sku = column_value(1).to_s.strip
    
    if gift_sku.blank?
      log_error("gift sku missing")
      return false
    end
    
    gift = Gift.where(wrapt_sku: gift_sku).first

    if gift.blank?
      log_error("gift not found with sku '#{gift_sku}'")
      return false
    end

    tag_list = column_value(3).to_s.strip
    
    gift.tag_list = tag_list

    if !gift.save
      log_error("Invalid tag list: '#{tag_list}'")
      return false
    end
  
    true
  end
  
  def column_value(column_number)
    @worksheet.cell(@row_number, column_number)
  end
  
  def log_error(message)
    if @row_number
      @errors << "#{@row_number}: #{message}"
    else
      @errors << message
    end
  end
 
end
