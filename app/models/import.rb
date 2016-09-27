class Import

  include ActiveModel::Model
  extend CarrierWave::Mount

  attr_accessor :records_file

  validates_presence_of :records_file
  validate :presence_of_headers

  def self.importable_name(name = nil, uploader_class = nil)
    if name.present?
      @_importable_name = name
      attr_accessor name
      alias_method :importable, name
      alias_method :importable=, "#{name}="

      mount_uploader :records_file, uploader_class
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

  def preload_one!(resource_class, column_name, lookup_attr_name, require_existence = true)
    @preloads ||= {}

    resource = @preloads[resource_class]
    if resource.nil?
      lookups = sheet.cached_columns[column_name]

      resource = resource_class.where(lookup_attr_name => lookups).index_by(&lookup_attr_name)

      if require_existence
        missing_lookups = lookups - resource.keys

        if missing_lookups.any?
          exception = Imports::Exceptions::PreloadsNotFound.new(resource_class, missing_lookups)
          add_exception(exception)
          raise exception
        end
      end

      @preloads[resource_class] = resource
    end
  end

  def save_records
    if valid?
      preload!

      sheet.each do |row|
        importable.send(record_association) << row_record(row)
      end

      importable.save
    else
      false
    end
  end

  #

  def add_exception(exception)
    @_exceptions ||= []
    @_exceptions << exception
  end

  def sheet
    @_sheet ||= Imports::Sheet.new(records_file, importable.class.to_s.pluralize.constantize)
  end
end
