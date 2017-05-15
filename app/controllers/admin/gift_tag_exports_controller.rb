require 'fileutils'

module Admin
  class GiftTagExportsController < BaseController

    def create
      FileUtils.mkdir_p Rails.root.join("tmp", "gift_tag_exports")
      target_file_path = Rails.root.join("tmp", "gift_tag_exports", gift_tag_export_filename).to_s
      GiftTagFileExportJob.new.perform(target_file_path)
      send_file target_file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      CleanupExportTempfileJob.set(wait: 30.minutes).perform_later(target_file_path)
    end

    private def gift_tag_export_filename
      "wrapt_gift_tags_#{Time.now.strftime('%Y-%m-%d-%H%M%S%L')}.xlsx"
    end
    
    
  end
end