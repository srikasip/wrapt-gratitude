class CsvUploader < ApplicationUploader
  def extension_white_list
    %w{csv}
  end
end
