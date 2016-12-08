require 'fileutils'

module Admin
  class ProfileSetExportsController < BaseController
    before_action :set_profile_set

    def create
      FileUtils.mkdir_p Rails.root.join("tmp", "profile_set_exports")
      target_file_path = Rails.root.join("tmp", "profile_set_exports", profile_set_export_filename).to_s
      ProfileSetFileExportJob.new.perform(@profile_set, target_file_path)
      send_file target_file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      CleanupExportTempfileJob.set(wait: 30.minutes).perform_later(target_file_path)
    end

    private def set_profile_set
      @profile_set = ProfileSet.find params[:profile_set_id]
    end

    private def profile_set_export_filename
      "wrapt_response_set_#{@profile_set.name.underscore}_#{Time.now.strftime('%Y-%m-%d-%H%M%S%L')}.xlsx"
    end
    
    
  end
end