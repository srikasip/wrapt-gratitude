class UserImport

  include ActiveModel::Model
  include ActionView::Helpers::SanitizeHelper
  extend CarrierWave::Mount

  attr_accessor :records_file
  validates :records_file, presence: true
  attr_reader :users_created_count, :row_errors

  mount_uploader :records_file, ExcelImportRecordsFileUploader

  def save_records
    if valid?
      @users_created_count = 0
      @row_errors = []
      @roo_sheet = Roo::Excelx.new(records_file.file.file)

      row_n = 1
      @roo_sheet.each_row_streaming(offset: 1, pad_cells: true) do |row|
        row_n += 1
        user = User.new
        row_values = row.map {|cell| strip_tags cell.value.to_s}
        next unless row_values.any?(&:present?)
        user.first_name, user.last_name, user.email, unmoderated_testing_platform = row_values
        user.unmoderated_testing_platform = unmoderated_testing_platform.presence
        user.setup_activation
        user.source = :admin_invitation
        if user.save
          UserActivationsMailer.activation_needed_email(user).deliver_later
          @users_created_count += 1
        else
          @row_errors << [row_n, user.errors]
        end
      end
      return true
    else
      return false
    end  
  end

end
