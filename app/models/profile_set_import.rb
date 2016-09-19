class ProfileSetImport

  include ActiveModel::Model
  extend CarrierWave::Mount

  REQUIRED_HEADERS = ProfileSetImportRow::ATTRIBUTE_HEADERS + %w{numeric_response_1}

  attr_accessor :profile_set, :question_responses_file

  mount_uploader :question_responses_file, ProfileSetImportResponsesFileUploader

  validates_presence_of :question_responses_file
  validate :presence_of_headers

  def presence_of_headers
    if question_responses_file.present?
      absent_headers = REQUIRED_HEADERS - header_row
      if absent_headers.any?
        count = absent_headers.count
        errors.add(
          :question_responses_file,
          "#{absent_headers.to_sentence} #{count == 1 ? 'was' : 'were'} "+
            "missing from the header row. Please make sure "+
            "#{count == 1 ? 'it is' : 'they are'} there at the top "+
            "of the proper #{'column'.pluralize(absent_headers.count)}."
        )
      end
    end
  end

  def save_question_responses
    header_order = header_row - ['numeric_response_1', 'numeric_response_2', 'etc']

    (2..sheet.count).reduce(0) do |success_count, row_number|
      row = ProfileSetImportRow.init_by_array(header_order, sheet.row(row_number))
      success_count + (row.save_question_response ? 1 : 0)
    end
  end

  #

  def header_row
    @_header_row ||= sheet.row(1)
  end

  def sheet
    @_sheet ||= Roo::Spreadsheet.open(question_responses_file.file)
  end
end
