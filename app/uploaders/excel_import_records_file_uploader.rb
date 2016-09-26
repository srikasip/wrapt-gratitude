class ExcelImportRecordsFileUploader < ApplicationUploader
  def extension_white_list
    %w{xlsx xls}
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}"
  end
end
