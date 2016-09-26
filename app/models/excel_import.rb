class ExcelImport

  include ActiveModel::Model
  extend CarrierWave::Mount

  attr_accessor :records_file

  mount_uploader :records_file, ExcelImportRecordsFileUploader

  validates_presence_of :records_file
  validate :presence_of_headers

  def self.importable_name(name = nil)
    if name.present?
      @_importable_name = name
      attr_accessor name
    end
    @_importable_name
  end

  def presence_of_headers
    if records_file.present?
      absent_headers = required_headers - sheet.header_row
      if absent_headers.any?
        count = absent_headers.count
        errors.add(
          :records_file,
          "#{absent_headers.to_sentence} #{count == 1 ? 'was' : 'were'} "+
          "missing from the header row. Please make sure "+
          "#{count == 1 ? 'it is' : 'they are'} there at the top of the "+
          "proper #{'column'.pluralize(count)}."
        )
      end
    end
  end

  #

  def add_exception(exception)
    @_exceptions ||= []
    @_exceptions << exception
  end

  def sheet
    @_sheet ||= "#{self.class.importable_name.to_s.camelcase.pluralize}::Imports::Sheet".constantize.new(records_file)
  end
end
